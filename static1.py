import sys
import os

if len(sys.argv) != 3:
    print("static dir threshold")
    sys.exit()

dirpath = sys.argv[1]
threshold = int(sys.argv[2])

def process_log_file(filepath):
    with open(filepath) as fp:
        for line in open(filepath):
            if line.startswith('exceptionMessage'):
                _, error = line.split(':', 1)
                return error.strip()
    print (filepath)
    # raise Exception("WTF")

static = {}
for root, dir, files in os.walk(dirpath):
    for filename in files:
        if not filename.endswith('.log'):
            continue

        filepath = os.path.join(root, filename)
        error = process_log_file(filepath)
        if error in static:
            static[error].append(filepath)
        else:
            static[error] = [filepath]

result = []
for k in static.keys():
    result.append((k, len(static[k])))

result = sorted(result, key = lambda x: x[1])
result.reverse()
for (k,n) in result:
    if n > threshold:
        print '-- exceptionMessage: %d, %s' % (n, k)
