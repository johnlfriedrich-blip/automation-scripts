print("run_all_tests.py loaded")

import subprocess
import os

HARNESSES = [
    "Python/test_parser_harness.py",
    "Python/test_config_loader_harness.py"
]

def run_harness(path):
    print(f"\n🔧 Running: {path}")
    try:
        result = subprocess.run(["python", path], capture_output=True, text=True)
        print(result.stdout)
        if result.stderr:
            print("⚠️ STDERR:", result.stderr)
    except Exception as e:
        print(f"❌ Failed to run {path}: {e}")

def main():
    print("🧪 Unified Test Runner Started")
    for harness in HARNESSES:
        if os.path.exists(harness):
            run_harness(harness)
        else:
            print(f"❌ Harness not found: {harness}")
    print("\n✅ All harnesses executed.")

if __name__ == "__main__":
    main()