# Finite Element Model of the WINDY Wind Tunnel Model fitted with the 'Lite' Folding Wingtip
Package Author: R Cheung

Contact: r.c.m.cheung@bristol.ac.uk

Updated: 08 December 2020

-------------------
Main File
-------------------
- sol144.bdf

-------------------
Dependency
-------------------
- aero.bdf
- fem.bdf
- hingelock.bdf
- litewingtip.bdf

-------------------
Options
-------------------
(1) Exclude call to 'hingelock.bdf' in 'sol144.bdf' for free-hinge configuration.

(2) 'litewingtip.bdf' includes an option for varying the wingtip's internal mass distribution.

-------------------
Supplementary Files
-------------------
- sol101.bdf for linear static analysis
- sol103.bdf for normal mode analysis
