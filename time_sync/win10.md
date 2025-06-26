# Reset default configuration
```powershell
w32tm /unregister
w32tm /register
net stop w32time
net start w32time
w32tm /resync
```

# Change default ntp time server
```powershell
w32tm /config /manualpeerlist:"pool.ntp.org,0x8" /syncfromflags:manual /reliable:yes /update
net stop w32time
net start w32time
w32tm /resync
```
