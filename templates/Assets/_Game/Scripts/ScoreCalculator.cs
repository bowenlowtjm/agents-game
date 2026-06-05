using UnityEngine;

namespace Pully.Game
{
    // Pure scoring logic — no scene, no MonoBehaviour — so it's fast to unit-test
    // in EditMode. Mirrors spec/RULESET.md (combo step, cap, score rounding).
    // The agent extends this as the core loop grows; keep it pure/testable.
    public static class ScoreCalculator
    {
        public const float StartingCombo = 1f;

        // Advance the combo multiplier by one correct hit, clamped to the cap.
        public static float NextCombo(float currentCombo, float step, float cap)
            => Mathf.Min(currentCombo * step, cap);

        // Points awarded for a hit at the given base reward and combo multiplier.
        public static int ScoreFor(int baseReward, float combo)
            => Mathf.RoundToInt(baseReward * combo);
    }
}
