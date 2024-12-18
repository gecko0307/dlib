$env:PATH += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64"
mt.exe -manifest main.manifest -outputresource:main.exe;1
