   ! --------------------------- gal-trader4.h ------------------------------
   record event_type
           SINGLE p1
           STRING source = 4
           STRING dest = 4
           STRING event = 2
   end record event_type

   record planetinfo_type
           SINGLE zone
           SINGLE law
           SINGLE population
           SINGLE tech
           SINGLE xp
           STRING pname = 15
           SINGLE yp
           SINGLE government
           SINGLE trade
   END RECORD planetinfo_type

   record score_type
           STRING sname = 10
           SINGLE ships
           INTEGER score
           STRING rank = 12
           SINGLE legal
           SINGLE money
   END RECORD score_type

   record equip_type
           SINGLE eprice
           STRING ename =20
           INTEGER usedeprice
   END RECORD equip_type

   record cargo_type
           SINGLE ttech
           SINGLE qtrade
           SINGLE tprice
           STRING unit
           SINGLE pprice
           SINGLE bprice
           STRING trade = 20
   END RECORD cargo_type

   record shipstats_type
           SINGLE soldhere
           SINGLE mmissile
	   INTEGER temperature
           STRING sname = 40
           SINGLE slaser
           SINGLE mlaser
           SINGLE mcargo
           SINGLE mfuel
           SINGLE cargo(2)
           SINGLE mdrive
           SINGLE rarity
           SINGLE reliability
           SINGLE resale
           SINGLE cost
	   INTEGER neg_cost
           SINGLE menergy
    END RECORD shipstats_type
    
    record targets_type
           STRING  username=4
           SINGLE others(2)
           SINGLE sintent
           SINGLE spos
	   SINGLE special
           SINGLE senergy
           SINGLE cargo(2)
           SINGLE smissile
           SINGLE player
           SINGLE ship
           SINGLE starget
    END RECORD targets_type

    record player_type
           SINGLE score
           SINGLE moves
           SINGLE credits
           SINGLE legal
           SINGLE date(2)
           SINGLE hash
           SINGLE interest
	   STRING username=4
           SINGLE due
           SINGLE pmode
           SINGLE rank
           SINGLE planet
           SINGLE kills
           SINGLE equip(ntequip)
           LONG timestamp(2)
           SINGLE chan2
           SINGLE escapes
           SINGLE debt
           SINGLE maxenergy
           SINGLE rpos
           SINGLE direction
           SINGLE time_owned
           SINGLE fshield
           SINGLE scanrange
           SINGLE shiptype
           SINGLE fuel
           SINGLE thargoid
           SINGLE shipnum
	   INTEGER lsj
           SINGLE energy
           STRING personalname = 13
           SINGLE maxfuel
           SINGLE chan1
           SINGLE maxcargo
           SINGLE ban
           SINGLE maxmissile
           SINGLE totcargo
           STRING message=bufsize
           SINGLE cargo(ntcargo)
           SINGLE on_ground
           SINGLE dodge
           SINGLE speed
           SINGLE random_key
	   INTEGER cloak
    END RECORD player_type
