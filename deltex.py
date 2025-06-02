import os

for filename in os.listdir(os.curdir+"/textures"):
    file_path = os.path.join(os.curdir+"/textures", filename)
    if os.path.isfile(file_path):
        if filename.endswith('.tex'):
            os.remove(file_path)