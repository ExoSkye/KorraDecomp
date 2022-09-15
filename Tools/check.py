import subprocess, sys, os


if len(sys.argv) != 3:
    raise Exception("Please provide a hash list to check against and a directory to check")
    
hash_file_path = os.path.join(os.getcwd(), sys.argv[1])

stdout = ""

if not os.path.exists(os.path.join(sys.argv[2], ".hash_correct")):
    sha_ver = subprocess.run(["sha512sum", "-c", hash_file_path], capture_output=True, cwd=sys.argv[2])
    stdout = sha_ver.stdout.decode()

if "FAILED" in stdout:
    print("Hash check failed")
    sys.exit(1)

else:
    print("Hash check succeeded")
    os.system(f"touch {sys.argv[2]}/.hash_correct") 
    sys.exit(0)
