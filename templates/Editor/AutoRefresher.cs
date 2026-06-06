using UnityEditor;
using UnityEngine;

// Headless compile + error check — lets an agent refresh/compile and read errors
// WITHOUT clicking into the Editor (Unity otherwise pauses compilation until the
// window regains focus). Lives in the Pully.EditorTools assembly, which does NOT
// reference the game assembly, so it still compiles and runs even when the GAME
// code is broken — which is exactly when you need the error check.
//
// CLI mode (project NOT open in another Editor):
//   <Unity> -batchmode -quit -projectPath . \
//           -executeMethod AutoRefresher.RefreshAndExit \
//           -logFile Logs/compile.log
// Exit code: 0 = clean, 1 = compile errors. Detail is in Logs/compile.log
// (grep for "error CS"). See scripts/unity-check.sh for the wrapper.
public static class AutoRefresher
{
    // Force Unity to import changed files and compile.
    public static void RefreshAssets()
    {
        AssetDatabase.Refresh(ImportAssetOptions.ForceUpdate);
    }

    // Refresh, then exit non-zero if the last script compilation failed so the
    // agent's shell loop can branch on the exit code.
    public static void RefreshAndExit()
    {
        AssetDatabase.Refresh(ImportAssetOptions.ForceUpdate);
        bool failed = EditorUtility.scriptCompilationFailed;
        if (failed)
            Debug.LogError("[AutoRefresher] Script compilation FAILED — see log for 'error CS' lines.");
        else
            Debug.Log("[AutoRefresher] Compile clean.");
        EditorApplication.Exit(failed ? 1 : 0);
    }
}
