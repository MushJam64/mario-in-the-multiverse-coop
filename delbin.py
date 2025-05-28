import os

for filename in os.listdir(os.curdir+"/actors"):
    file_path = os.path.join(os.curdir+"/actors", filename)
    if os.path.isfile(file_path):
        if filename.endswith('.bin') or filename.endswith('.col'):
            os.remove(file_path)
for filename in os.listdir(os.curdir+"/data"):
    file_path = os.path.join(os.curdir+"/data", filename)
    if os.path.isfile(file_path):
        if filename.endswith('.bhv'):
            os.remove(file_path)