using System.Collections;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace Pully.Tests
{
    // Sample INTEGRATION (PlayMode) test — passes on a fresh scaffold so CI is
    // green from commit 0. The agent replaces/extends this with real tests:
    //   load the game scene, simulate touches via InputTestFixture, assert score
    //   + combo update, lives/timer, game-over, and deterministic replay.
    public class SmokePlayModeTests
    {
        [UnityTest]
        public IEnumerator GameObject_Survives_AFrame()
        {
            var go = new GameObject("probe");
            yield return null; // advance one frame in PlayMode
            Assert.IsNotNull(go);
            Object.Destroy(go);
        }
    }
}
