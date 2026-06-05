using NUnit.Framework;
using Pully.Game;

namespace Pully.Tests
{
    // Sample UNIT test — passes on a fresh scaffold so CI is green from commit 0.
    // The agent adds tests for gesture classification, ruleset lookup, spawn
    // determinism, and combo-reset-on-miss here.
    public class ScoreCalculatorTests
    {
        [Test]
        public void NextCombo_AppliesStep()
        {
            Assert.AreEqual(1.1f, ScoreCalculator.NextCombo(1f, 1.1f, 5f), 1e-4f);
        }

        [Test]
        public void NextCombo_ClampsToCap()
        {
            Assert.AreEqual(5f, ScoreCalculator.NextCombo(4.8f, 1.1f, 5f), 1e-4f);
        }

        [TestCase(1, 1f, 1)]
        [TestCase(8, 1.1f, 9)]   // 8 * 1.1 = 8.8 -> 9
        [TestCase(5, 5f, 25)]
        public void ScoreFor_RoundsToNearest(int baseReward, float combo, int expected)
        {
            Assert.AreEqual(expected, ScoreCalculator.ScoreFor(baseReward, combo));
        }
    }
}
