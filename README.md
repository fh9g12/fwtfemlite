# Finite Element Model of the WINDY Wind Tunnel Model fitted with the 'Lite' Folding Wingtip
Package Author: Fintan Healy

Contact: fintan.healy@bristol.ac.uk

Updated: 17 June 2021

-------------------
Main File
-------------------
- sol101.bdf
- sol103.bdf
- sol144.bdf
- sol145.bdf

-------------------
Dependency
-------------------
- aero.bdf
- fem.bdf
- flutter.bdf
- fwtcoord.bdf
- hinge.bdf
- litewingtip.bdf

-------------------
Options
-------------------
(1) Exclude call to 'hingelock.bdf' in 'sol144.bdf' for free-hinge configuration.

(2) 'litewingtip.bdf' includes an option for varying the wingtip's internal mass distribution.

-------------------
Supplementary Files
-------------------
- matlab folder contains code to auto generate the aero, flutter, fwtcoord, and hinge bdf files
