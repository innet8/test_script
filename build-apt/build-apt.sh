#!/bin/bash
author=hcw
appname=test-app
version=$(date +%s)

mkdir -p $appname-$version/DEBIAN
mkdir -p $appname-$version/etc/$appname
mkdir -p $appname-$version/usr/bin/

cat >$appname-$version/usr/bin/$appname <<EOF
#!/bin/bash
cat /etc/$appname/config.json|jq
EOF

cat >$appname-$version/preinst <<EOF
#!/bin/bsh
echo "Pre execution script"
echo "init server"
EOF

cat >$appname-$version/postinst <<EOF
#!/bin/bsh
echo "Post execution script"
echo "start server"
EOF

cat >$appname-$version/prerm <<EOF
#!/bin/bsh
echo "Pre execution script"
echo "stop server "
EOF

cat >$appname-$version/postrm <<EOF
#!/bin/bsh
echo "Post execution script"
echo "remove init env "
EOF

cat >$appname-$version/DEBIAN/control <<EOF
Package: $appname
Version: ${version}
Section: utils
Priority: optional
Architecture: amd64
Depends: libc6 (>= 2.15), jq
Maintainer: 751164212@qq.com
Description:  ${author} ${appname} describe 
EOF

chmod +x $appname-$version/{preinst,postinst,prerm,postrm}

chmod 755 $appname-$version/usr/bin/$appname

cat >$appname-$version/etc/$appname/config.json <<EOF
{
  "test": 1
}
EOF

dpkg-deb --build $appname-$version
curl -u "admin:W6RS6I2T8nkPWDrwBC" -H "Content-Type: multipart/form-data" --data-binary "@$appname-$version.deb" "http://nexus-web.keli.vip/repository/apt-hub/"

ls -l $appname-$version
tree $appname-$version
echo """上传完毕 curl -u "admin:W6RS6I2T8nkPWDrwBC" -H "Content-Type: multipart/form-data" --data-binary "@$appname-$version.deb" "http://nexus-web.keli.vip/repository/apt-hub/""""

apt-get update
apt-get install test-app


#环境前提
# cat >private.gpg.key<<EOF
# -----BEGIN PGP PRIVATE KEY BLOCK-----
# lQPFBGU4bq8BCADfPtFTUBcQXrXrHbDp1apWp8tEIki5w64vxX9vqtbxBb4JWQnW
# nGjylTao4l2KPxxl1DpXQDseSnlhnBdl6sLnHUJBCM5R5YqTS88iHpiSVjEF2Z/9
# o+D4A7mkwxoJlL6w482xzstpv64cDxZuoCezwUUnVsn49HH4DHTFy9xtj1ktx2lw
# GhO+jP9wMiKd8gF4DhwezY1HbuIH8SRd8GZNj5v/GvJo2B2SaWie6bpzOL5o9Ppj
# LVYucra1+eBNMLM+vvlZE5zBTj0lAfkBLl4a20pF/6+/H9XW058f9vTSGnDL7y1M
# TW9rP3qUGYKYb6uU92RHnO5JsdL8rleWDsxLABEBAAH+BwMCKT9p1QkiocT/bDl1
# wbemp4YKUlDtIoXlPu8WoD6BvKjvbBSXnhyJBx3f1lI+zipMHrKIgJL0TyzqNx8R
# +yNOj/dDNHOZeJRdK/oOlY9wj0Vdf2qUQfCr6C+rBMnGGMZzlA198DKQnXlYR51z
# 8bW5/TJzAH3eyaRkX47LO24F+bC0YK6+Fr3yj0/rg0ztrpLhr4HPfq+iiSHXP1An
# TXchyD+WV854DX7Q1uANL43Ng7S5D5qARl8wxLKlw1C0e7MLCycUhfTX4iho42ec
# 3DKM7kGfVCGectdN70pZg9SUKprUOoX9zrPug7SPmlLR+tnEZYiDr6yWhgcIxGb5
# jqUVid4mOPNT4e38MBKjxID6s5US/xOhw8YvkfAsWcoBVkZv7iL1ZwGDvE6imN1X
# ctpdU5VyqBe++UPEcEARmCoE6+FUQy/Iy5AFeeCKUMR1Blp2pSj+QqMOjYijOjQ+
# BEPC2QY2+Kr5mbg5mH5//dLpYIiJbedV87MJ3vQYaT7t41q535X5YJ6BJaZcwQ1C
# o+zMbn4CZJMdK4nPnXFCOLkkrIovX9UwJGTnIS0B7oBAwXidpUwiLttBkUOdXkjc
# s81s9Za8hXRAHv+Hxz/os087Rn5m5Y6uXeLAuXWxDz9rqsjvEdr35WJDYMCPiLyD
# fP2PlbZzYnT4+6fkuuCpNo7GBEqwfcWzlB5KjFJu8+ZoJrBpVZfYLmLQWKqMPxDr
# HOgSRDgyFZ0uFOIs9ZdQ3iP1IlJbsaBEk9k/yyu6DG99MkSqeTJg5F13RCvSBcoU
# xt0CBK3Kiaol5tXyDGnpZjtgTTNWWIJfKT2SSr1Dzc/OsboV8D2DzInmN1Jt+jsU
# XoXu0U9NSEg4PQ1FXzmiaaURVylXI41gGyy3Hs/veHtW2kmgxlxr3zChhpf/cxaU
# rdWrZMBNYeu0CnVidW50dS1hcHSJAU4EEwEKADgWIQTAcnXpAkPeAMiyJ3QA7UG3
# RP8zQgUCZThurwIbAwULCQgHAgYVCgkICwIEFgIDAQIeAQIXgAAKCRAA7UG3RP8z
# QhHXB/967nfBtC53alhY5RjoXNLvHXgXiefOMYfg23BUerTQHuzCJU5z3uqLjul6
# lYnRTFyE/TLBTCNmYqiBqEpagzCFAWf1s6fbqm08P1XN6MLlykI9bJmRBk1evLQv
# PIO521/TxlTkZhdWKkUwXnu1QYt6c+kH0LFRKE3LRPieAxBbmDVo1eRyirflCeFT
# OenfT59GOwv7oipgphGGeuc4qqwSehukWGSH6EVbJ5m+6dxyyr89NLxy4hChz5zW
# FpJWwp0d+u/jzOrPxmbEDDJmWuvB9C1b1I4PIC78llWvXBctUl/DFK7ISQk7IFjI
# sQ7EbaJxXXbt+6IBvXU4xczmf2FonQPGBGU4bq8BCADzxjeyJ0r6dnYJIZpG/BfA
# Wgtv1K0Lqb4K35HZT7/e3g0MzeayDCpmVVoOexIhwiFSW2wVCeZb7ib9l/jE2urB
# 74fKuAOBIOGBqygkSF2jqXvedTWHizGBWK281LUhfJp7khHw+WplNie6fmBryVW+
# wJ4EgZJXOGKeLSsFynTrX7T16QDHSVsAeDKZfaOHZ6CES0yTYVzJkRx3ZSXmrSY9
# XscRNAnbUPFDBFbTMXtboXQtUCpqYX10267jTKKfgVD/dEtA+rb3VtXZlgX2FBQR
# Jl/DtxUKD5ORXfTyEAe5Ho3/4tRorHctclIGEIzZ0K7Q+WgnZYVBblt24/mw768V
# ABEBAAH+BwMCJt4+gne3D3L/8z+Gzsi++pC1TxvtIGwStLWW/utKIBZ+hIz/D2Ao
# 0RDaQvW0fZSAanVA2LQKv9j43fN24pg94PXXFg4zKL1Zxxds6ZfobJx08/BJtWmm
# 6R43uQBs3SWlXhqpXyiwjVWlfvdCGZcIoiDWH3TrasD1hjm3krZVqe3tM0aCSoPx
# BQimPSw9CQz45rSux93+E8sU2ZsG4kcsydzyVqnCEE61lH+5euBEoTAOW6Q04ue8
# MrjEOM1ljXOYoeUgj7NjoLhLJgCPwBQAsPwc5uK3PW0E4z0Q7jKJgYQOH2q9zFez
# HxKqPX0xZuji9k1kO8/ov7KAbD+BWuvLxVX/iJ0C+WmD1qc+W+tN7AjH1gIP/Wsj
# JztsySkn/CiRk+2aqBZjuKRFi3dmo/HfXZmgGdw2CwB3hHSM+xJbmXWE3LAS6NQo
# Za3BSFcAMG9DUxybH0z7opFpEoXky/MwBdaPKljHWW/JnH7+mqZxh9UBM205VPps
# loau+XpxF2/bvBRbC5mzY7WJUZ21NFwJFyx+KNhKWr1Em55LMMLcTIppP+X0Gmm+
# yE026qWqSe5qM8esNYYhpVKa5LR2XqX7pZ4foksJAlCJ3Q3SC0Vgq9S6kWzrKnfJ
# hRwMaVU7CntiDC7mwe16fRyDAoxCySshPt1FYlwi6bJodJA4gGRZ3PaFiceQ5jGy
# DkTwdQci5ld8B/lvQhwavFP7u7PS3R/ibCmPVEHkMbfeVIWzze/DrwW0ZNNpziHb
# 64rTayrkyFQy5IceJu3B7QeY2Rlt4XBxBa7Ep1UBxwuGe6HFXtmFSYmilSvepCZI
# HYLsOtD1VPxmJGPMwZePoMbp+HJWVnEzauC5DQNXp7jytLjSHhVN66z5F5awHMel
# jPQb2cF6CCrf52kLLfJPCUkdi2XNzE5vXgdA6d7YiQE2BBgBCgAgFiEEwHJ16QJD
# 3gDIsid0AO1Bt0T/M0IFAmU4bq8CGwwACgkQAO1Bt0T/M0LTAAgAqqS6DOwk596j
# j9hp+MUMSU0vFMIhYzgYhGW3CjQG5E/MFI3D1njJ/pWrQ0Bdp0l+G7BM8W8YVFJ3
# xAqANiJRFIH92UjtA8IfcTqJ5yQblDjF18tisWJwwlCbOpvDjjxsD3QEz0Zi7tJA
# /J6pCGpvou9/DxtA3iQGDRPhsr4S8ip+JzD/sgLRp0P0EqN1kQDa2o9bExTZNDln
# 676XEz2PKTRpwiwwFfEzCrclCqlIFKB50WOy9xzDOrzrpHOLxxqULQ/ljnbnEzAD
# i4s8IjS5+BcxugA0iHBkjIyCOwrAmBd56wzCGuoF/WjhakMhGN9A6jEz1hVB8aHD
# CtBOecf9ZQ==
# =pSJt
# -----END PGP PRIVATE KEY BLOCK-----
# EOF

# cat >public.gpg.key<<EOF
# -----BEGIN PGP PUBLIC KEY BLOCK-----

# mQENBGU4bq8BCADfPtFTUBcQXrXrHbDp1apWp8tEIki5w64vxX9vqtbxBb4JWQnW
# nGjylTao4l2KPxxl1DpXQDseSnlhnBdl6sLnHUJBCM5R5YqTS88iHpiSVjEF2Z/9
# o+D4A7mkwxoJlL6w482xzstpv64cDxZuoCezwUUnVsn49HH4DHTFy9xtj1ktx2lw
# GhO+jP9wMiKd8gF4DhwezY1HbuIH8SRd8GZNj5v/GvJo2B2SaWie6bpzOL5o9Ppj
# LVYucra1+eBNMLM+vvlZE5zBTj0lAfkBLl4a20pF/6+/H9XW058f9vTSGnDL7y1M
# TW9rP3qUGYKYb6uU92RHnO5JsdL8rleWDsxLABEBAAG0CnVidW50dS1hcHSJAU4E
# EwEKADgWIQTAcnXpAkPeAMiyJ3QA7UG3RP8zQgUCZThurwIbAwULCQgHAgYVCgkI
# CwIEFgIDAQIeAQIXgAAKCRAA7UG3RP8zQhHXB/967nfBtC53alhY5RjoXNLvHXgX
# iefOMYfg23BUerTQHuzCJU5z3uqLjul6lYnRTFyE/TLBTCNmYqiBqEpagzCFAWf1
# s6fbqm08P1XN6MLlykI9bJmRBk1evLQvPIO521/TxlTkZhdWKkUwXnu1QYt6c+kH
# 0LFRKE3LRPieAxBbmDVo1eRyirflCeFTOenfT59GOwv7oipgphGGeuc4qqwSehuk
# WGSH6EVbJ5m+6dxyyr89NLxy4hChz5zWFpJWwp0d+u/jzOrPxmbEDDJmWuvB9C1b
# 1I4PIC78llWvXBctUl/DFK7ISQk7IFjIsQ7EbaJxXXbt+6IBvXU4xczmf2FouQEN
# BGU4bq8BCADzxjeyJ0r6dnYJIZpG/BfAWgtv1K0Lqb4K35HZT7/e3g0MzeayDCpm
# VVoOexIhwiFSW2wVCeZb7ib9l/jE2urB74fKuAOBIOGBqygkSF2jqXvedTWHizGB
# WK281LUhfJp7khHw+WplNie6fmBryVW+wJ4EgZJXOGKeLSsFynTrX7T16QDHSVsA
# eDKZfaOHZ6CES0yTYVzJkRx3ZSXmrSY9XscRNAnbUPFDBFbTMXtboXQtUCpqYX10
# 267jTKKfgVD/dEtA+rb3VtXZlgX2FBQRJl/DtxUKD5ORXfTyEAe5Ho3/4tRorHct
# clIGEIzZ0K7Q+WgnZYVBblt24/mw768VABEBAAGJATYEGAEKACAWIQTAcnXpAkPe
# AMiyJ3QA7UG3RP8zQgUCZThurwIbDAAKCRAA7UG3RP8zQtMACACqpLoM7CTn3qOP
# 2Gn4xQxJTS8UwiFjOBiEZbcKNAbkT8wUjcPWeMn+latDQF2nSX4bsEzxbxhUUnfE
# CoA2IlEUgf3ZSO0Dwh9xOonnJBuUOMXXy2KxYnDCUJs6m8OOPGwPdATPRmLu0kD8
# nqkIam+i738PG0DeJAYNE+GyvhLyKn4nMP+yAtGnQ/QSo3WRANraj1sTFNk0OWfr
# vpcTPY8pNGnCLDAV8TMKtyUKqUgUoHnRY7L3HMM6vOukc4vHGpQtD+WOducTMAOL
# izwiNLn4FzG6ADSIcGSMjII7CsCYF3nrDMIa6gX9aOFqQyEY30DqMTPWFUHxocMK
# 0E55x/1l
# =6GPh
# -----END PGP PUBLIC KEY BLOCK-----
# EOF
## 密码W6RS6I2T8nkPWDrwBC

#apt-key add public.gpg.key 
# /etc/apt/sources.list
#deb http://nexus-web.keli.vip/repository/apt-hub focal main

