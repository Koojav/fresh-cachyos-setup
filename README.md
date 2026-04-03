# Running games on Steam 

Set compatibility to: `proton-cachyos-10.x-YYYYMMDD`

Use following launch options 
```
gamemoderun PROTON_ENABLE_NVAPI=1 DXVK_ENABLE_NVAPI=1 DXVK_NVAPI_ALLOW_OTHER_DRIVERS=1 %command%
```

to enabled:
- gamemode: various OS optimizations
- DLSS via Proton
