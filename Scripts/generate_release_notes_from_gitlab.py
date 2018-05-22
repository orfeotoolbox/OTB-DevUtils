import requests
import sys
import json

def format_mr(mr):
    return "!{}: {} by {} (see https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb/merge_requests/{})".format(mr['iid'],mr['title'].encode('utf-8'),mr['author']['name'].encode('utf-8'),mr['iid'])

# Project id for otb
id=53

if len(sys.argv)!=3:
    print("Usage: {} release_name(ex: 6.6.0) last_release_date(ex: 2017-12-22)".format(sys.argv[0]))

    exit(1)

milestone = sys.argv[1]
last_release_date = sys.argv[2]

# Merge Requests with milestone M.m.p
req="https://gitlab.orfeo-toolbox.org/api/v4/projects/53/merge_requests?scope=all&status=merged&milestone={}".format(milestone)
r = requests.get(req,verify=False)
data = json.loads(r.text)

#Merge Requests merged in develop after branching to last release
req="https://gitlab.orfeo-toolbox.org/api/v4/projects/53/merge_requests?scope=all&status=merged&target_branch=develop&updated_after={}".format(last_release_date)
r = requests.get(req,verify=False)
data+=json.loads(r.text)


data = sorted(data, key=lambda data: data['iid'])

bugs = []
patches = []
features = []
remaining = []

for mr in data:
    if "bug" in mr['labels']:
        bugs.append(mr)
    elif "feature" in mr['labels']:
        features.append(mr)
    elif "patch" in mr['labels']:
        patches.append(mr)
    else:
        remaining.append(mr)

print("\nFeatures added: ")
for mr in features:
    print("   * "+format_mr(mr))

print("\nBugs fixed:")        
for mr in bugs:
    print("   * "+format_mr(mr))

print("\nSmall patches made:")
for mr in patches:
    print("   * "+format_mr(mr))

print("\nOther changes:")
for mr in remaining:
    print("   * "+format_mr(mr))


