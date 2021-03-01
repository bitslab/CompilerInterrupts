#!/bin/bash
dot -Tpng cfg.INITIA.dot -o INITIA.png
dot -Tpng cfg.xrand.dot -o xrand.png
dot -Tpng cfg.CSHIFT.dot -o CSHIFT.png
dot -Tpng cfg.BNDRY.dot -o BNDRY.png
dot -Tpng cfg.PREDIC.dot -o PREDIC.png
dot -Tpng cfg.CORREC.dot -o CORREC.png
dot -Tpng cfg.KINETI.dot -o KINETI.png
dot -Tpng cfg.CNSTNT.dot -o CNSTNT.png
dot -Tpng cfg.INTERF.dot -o INTERF.png
dot -Tpng cfg.UPDATE_FORCES.dot -o UPDATE_FORCES.png
dot -Tpng cfg.POTENG.dot -o POTENG.png
dot -Tpng cfg.MDMAIN.dot -o MDMAIN.png
dot -Tpng cfg.main.dot -o main.png
dot -Tpng cfg.WorkStart.dot -o WorkStart.png
dot -Tpng cfg.INTRAF.dot -o INTRAF.png
dot -Tpng cfg.SYSCNS.dot -o SYSCNS.png
