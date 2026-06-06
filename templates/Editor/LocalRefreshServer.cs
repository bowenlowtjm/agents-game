using System;
using System.Collections.Generic;
using System.Net;
using System.Text;
using UnityEditor;
using UnityEditor.Compilation;
using UnityEngine;

// Live-Editor refresh server: keep the Editor open and trigger refresh + compile +
// error-read over HTTP — no window focus needed. Complements Unity MCP; useful as a
// reliable, MCP-independent verification primitive for autonomous runs.
//
// Port comes from env PULLY_REFRESH_PORT (default 8090) so PARALLEL runs don't
// collide (see 11-Parallel-Runs.md). Compile errors persist across the domain
// reload (that a recompile triggers) via SessionState.
//
// Agent usage:
//   curl http://localhost:<port>/refresh   -> queue a refresh/compile
//   (wait ~1-2s for the recompile)
//   curl http://localhost:<port>/errors    -> compile errors, or "CLEAN"
//   curl http://localhost:<port>/health    -> "ok"
[InitializeOnLoad]
public static class LocalRefreshServer
{
    private const string RawKey = "Pully.CompileErrors.raw";
    private static HttpListener _listener;

    static LocalRefreshServer()
    {
        CompilationPipeline.compilationStarted += _ => SessionState.SetString(RawKey, "");
        CompilationPipeline.assemblyCompilationFinished += OnAssemblyFinished;
        Start();
    }

    private static void OnAssemblyFinished(string assemblyPath, CompilerMessage[] messages)
    {
        var lines = new List<string>();
        foreach (var m in messages)
            if (m.type == CompilerMessageType.Error)
                lines.Add($"{m.file}({m.line},{m.column}): {m.message}");
        if (lines.Count > 0)
        {
            var prev = SessionState.GetString(RawKey, "");
            SessionState.SetString(RawKey, prev + string.Join("\n", lines) + "\n");
        }
    }

    private static int Port()
    {
        var s = Environment.GetEnvironmentVariable("PULLY_REFRESH_PORT");
        return int.TryParse(s, out var p) ? p : 8090;
    }

    private static async void Start()
    {
        try
        {
            _listener = new HttpListener();
            _listener.Prefixes.Add($"http://localhost:{Port()}/");
            _listener.Start();
            Debug.Log($"[LocalRefreshServer] listening on :{Port()} (/refresh, /errors, /health)");
        }
        catch (Exception e)
        {
            Debug.LogWarning($"[LocalRefreshServer] not started: {e.Message}");
            return;
        }

        while (_listener != null && _listener.IsListening)
        {
            HttpListenerContext ctx;
            try { ctx = await _listener.GetContextAsync(); }
            catch { break; } // listener torn down (e.g. domain reload)

            string path = ctx.Request.Url.AbsolutePath.TrimEnd('/');
            string body;
            switch (path)
            {
                case "/refresh":
                    EditorApplication.delayCall += () =>
                    {
                        SessionState.SetString(RawKey, "");
                        AssetDatabase.Refresh(ImportAssetOptions.ForceUpdate);
                    };
                    body = "refresh queued";
                    break;
                case "/errors":
                    var raw = SessionState.GetString(RawKey, "");
                    body = string.IsNullOrEmpty(raw) ? "CLEAN" : raw;
                    break;
                default:
                    body = "ok";
                    break;
            }

            var buf = Encoding.UTF8.GetBytes(body);
            ctx.Response.StatusCode = 200;
            ctx.Response.OutputStream.Write(buf, 0, buf.Length);
            ctx.Response.Close();
        }
    }
}
