/* object.c */
#include "header.h"
#include "larndefs.h"
#include "monsters.h"
#include "objects.h"
#include "player.h"

#define min(x,y) (((x)>(y))?(y):(x))
#define max(x,y) (((x)>(y))?(x):(y))

/* LOOK_FOR_OBJECT
 subroutine to look for an object and give the player his options if an object
 was found.
*/
lookforobject(do_ident, do_pickup, do_action)
    char            do_ident;   /* identify item: T/F */
    char            do_pickup;  /* pickup item:   T/F */
    char            do_action;  /* prompt for actions on object: T/F */
{
    register int    i, j;

    /* can't find objects if time is stopped    */
    if (c[TIMESTOP])
        return;
    i = item[playerx][playery];
    if (i == 0)
        return;
    j = iarg[playerx][playery];
    showcell(playerx, playery);
    cursors();
    yrepcount = 0;
    switch (i)
    {
    case OGOLDPILE:
    case OMAXGOLD:
    case OKGOLD:
    case ODGOLD:
        lprcat("\n\nYou have found some gold!");
        ogold(i);
        break;

    case OPOTION:
        if (do_ident)
        {
            lprcat("\n\nYou have found a magic potion");
            if (potionname[j][0])
                lprintf(" of %s", &potionname[j][1]);
        }
        if (do_pickup)
            if (take(OPOTION, j) == 0)
                forget();
        if (do_action)
            opotion(j);
        break;

    case OSCROLL:
        if (do_ident)
        {
            lprcat("\n\nYou have found a magic scroll");
            if (scrollname[j][0])
                lprintf(" of %s", &scrollname[j][1]);
        }
        if (do_pickup)
            if (take(OSCROLL, j) == 0)
                forget();
        if (do_action)
            oscroll(j);
        break;

    case OALTAR:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\n\nThere is a Holy Altar here!");
        if (do_action)
            oaltar();
        break;

    case OBOOK:
        if (do_ident)
            lprcat("\n\nYou have found a book.");
        if (do_pickup)
            if (take(OBOOK, j) == 0)
                forget();
        if (do_action)
            obook();
        break;

    case OCOOKIE:
        if (do_ident)
            lprcat("\n\nYou have found a fortune cookie.");
        if (do_pickup)
            if (take(OCOOKIE, 0) == 0)
                forget();
        if (do_action)
            ocookie();
        break;

    case OTHRONE:
        if (nearbymonst())
            return;
        if (do_ident)
            lprintf("\n\nThere is %s here!", objectname[i]);
        if (do_action)
            othrone(0);
        break;

    case OTHRONE2:
        if (nearbymonst())
            return;
        if (do_ident)
            lprintf("\n\nThere is %s here!", objectname[i]);
        if (do_action)
            othrone(1);
        break;

    case ODEADTHRONE:
        if (do_ident)
            lprintf("\n\nThere is %s here!", objectname[i]);
        if (do_action)
            odeadthrone();
        break;

    case OPIT:
        /* always perform these actions. */
        lprcat("\n\nYou're standing at the top of a pit.");
        opit();
        break;

    case OSTAIRSUP: /* up */
        if (do_ident)
            lprcat("\n\nThere is a circular staircase here");
        if (do_action)
            ostairs(1);
        break;

    case OFOUNTAIN:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\n\nThere is a fountain here");
        if (do_action)
            ofountain();
        break;

    case OSTATUE:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\n\nYou are standing in front of a statue");
        if (do_action)
            ostatue();
        break;

    case OCHEST:
        if (do_ident)
            lprcat("\n\nThere is a chest here");
        if (do_pickup)
            if (take(OCHEST, j) == 0)
                forget();
        if (do_action)
            ochest();
        break;

    case OSCHOOL:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\n\nYou have found the College of Larn.");
        if (do_action)
            prompt_enter();
        break;

    case OMIRROR:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\n\nThere is a mirror here");
        if (do_action)
            omirror();
        break;

    case OBANK2:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\n\nYou have found a branch office of the bank of Larn.");
        if (do_action)
            prompt_enter();
        break;

    case OBANK:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\n\nYou have found the bank of Larn.");
        if (do_action)
            prompt_enter();
        break;

    case ODEADFOUNTAIN:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\n\nThere is a dead fountain here");
        break;

    case ODNDSTORE:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\n\nThere is a DND store here.");
        if (do_action)
            prompt_enter();
        break;

    case OSTAIRSDOWN:   /* down */
        if (do_ident)
            lprcat("\n\nThere is a circular staircase here");
        if (do_action)
            ostairs(-1);
        break;

    case OOPENDOOR:
        if (do_ident)
            lprintf("\n\nYou have found %s", objectname[i]);
        if (do_action)
            o_open_door();
        break;

    case OCLOSEDDOOR:
        if (do_ident)
            lprintf("\n\nYou have found %s", objectname[i]);
        if (do_action)
            o_closed_door();
        break;

    case OENTRANCE:
        if (do_ident)
            lprcat("\nYou have found ");
        lprcat(objectname[i]);
        if (do_action)
            prompt_enter();
        break;

    case OVOLDOWN:
        if (do_ident)
            lprcat("\nYou have found ");
        lprcat(objectname[i]);
        if (do_action)
            prompt_volshaft(-1);
        break;

    case OVOLUP:
        if (do_ident)
            lprcat("\nYou have found ");
        lprcat(objectname[i]);
        if (do_action)
            prompt_volshaft(1);
        break;

    case OIVTELETRAP:
        if (rnd(11) < 6)
            return;
        item[playerx][playery] = OTELEPORTER;
        know[playerx][playery] = KNOWALL;
        /* fall through to OTELEPORTER case below!!! */

    case OTELEPORTER:
        lprcat("\nZaaaappp!  You've been teleported!\n");
        beep();
        nap(3000);
        oteleport(0);
        break;

    case OTRAPARROWIV:  /* for an arrow trap */
        if (rnd(17) < 13)
            return;
        item[playerx][playery] = OTRAPARROW;
        know[playerx][playery] = 0;
        /* fall through to OTRAPARROW case below!!! */

    case OTRAPARROW:
        lprcat("\nYou are hit by an arrow");
        beep();
        lastnum = 259;
        losehp(rnd(10) + level);
        bottomhp();
        return;

    case OIVDARTRAP:    /* for a dart trap */
        if (rnd(17) < 13)
            return;
        item[playerx][playery] = ODARTRAP;
        know[playerx][playery] = 0;
        /* fall through to ODARTTRAP case below!!! */

    case ODARTRAP:
        lprcat("\nYou are hit by a dart");
        beep();     /* for a dart trap */
        lastnum = 260;
        losehp(rnd(5));
        if ((--c[STRENGTH]) < 3)
            c[STRENGTH] = 3;
        bottomline();
        return;

    case OIVTRAPDOOR:   /* for a trap door */
        if (rnd(17) < 13)
            return;
        item[playerx][playery] = OTRAPDOOR;
        know[playerx][playery] = KNOWALL;
        /* fall through to OTRAPDOOR case below!!! */

    case OTRAPDOOR:
        lastnum = 272;  /* a trap door */
        if ((level == MAXLEVEL - 1) || (level == MAXLEVEL + MAXVLEVEL - 1))
        {
            lprcat("\nYou fell through a bottomless trap door!");
            beep();
            nap(3000);
            died(271);
        }
        i = rnd(5 + level);
        lprintf("\nYou fall through a trap door!  You lose %d hit points.", (long) i);
        beep();
        losehp(i);
        nap(2000);
        newcavelevel(level + 1);
        draws(0, MAXX, 0, MAXY);
        bot_linex();
        return;

    case OTRADEPOST:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\nYou have found the Larn trading Post.");
        if (do_action)
            prompt_enter();
        return;

    case OHOME:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\nYou have found your way home.");
        if (do_action)
            prompt_enter();
        return;

    case OWALL:
        break;

    case OANNIHILATION:
        died(283);  /* annihilated by sphere of annihilation */
        return;

    case OLRS:
        if (nearbymonst())
            return;
        if (do_ident)
            lprcat("\n\nThere is an LRS office here.");
        if (do_action)
            prompt_enter();
        break;

    default:
        if (do_ident)
        {
            lprintf("\n\nYou have found %s ", objectname[i]);
            switch (i)
            {
            case ODIAMOND:
            case ORUBY:
            case OEMERALD:
            case OSAPPHIRE:
            case OSPIRITSCARAB:
            case OORBOFDRAGON:
            case OCUBEofUNDEAD:
            case ONOTHEFT:
                break;

            default:
                if (j > 0)
                    lprintf("+ %d", (long) j);
                else
                if (j < 0)
                    lprintf(" %d", (long) j);
                break;
            }
        }
        if (do_pickup)
            if (take(i, j) == 0)
                forget();
        if (do_action)
        {
            char            tempc = 0;

            lprcat("\nDo you want to (t) take it");
            iopts();
            while (tempc != 't' && tempc != 'i' && tempc != '\33')
                tempc = ttgetch();
            if (tempc == 't')
            {
                lprcat("take");
                if (take(i, j) == 0)
                    forget();
                return;
            }
            ignore();
        }
        break;
    };
}


/*
 * subroutine to process the stair cases if dir > 0 the up else down 
 */
static ostairs(dir)
    int             dir;
{
    register int    k;
    lprcat("\nDo you (s) stay here ");
    if (dir > 0)
        lprcat("or (u) go up? ");
    else
        lprcat("or (d) go down? ");

    while (1)
        switch (ttgetch())
        {
        case '\33':
        case 's':
        case 'i':
            lprcat("stay here");
            return;

        case 'u':
            lprcat("go up");
            act_up_stairs();
            return;

        case 'd':
            lprcat("go down");
            act_down_stairs();
            return;
        };
}



/*
 * subroutine to handle a teleport trap +/- 1 level maximum 
 */
oteleport(err)
    int             err;
{
    register int    tmp;
    if (err)
        if (rnd(151) < 3)
            died(264);  /* stuck in a rock */
    c[TELEFLAG] = 1;    /* show ?? on bottomline if been teleported    */
    if (level == 0)
        tmp = 0;
    else
    if (level < MAXLEVEL)
    {
        tmp = rnd(5) + level - 3;
        if (tmp >= MAXLEVEL)
            tmp = MAXLEVEL - 1;
        if (tmp < 1)
            tmp = 1;
    } else
    {
        tmp = rnd(3) + level - 2;
        if (tmp >= MAXLEVEL + MAXVLEVEL)
            tmp = MAXLEVEL + MAXVLEVEL - 1;
        if (tmp < MAXLEVEL)
            tmp = MAXLEVEL;
    }
    playerx = rnd(MAXX - 2);
    playery = rnd(MAXY - 2);
    if (level != tmp)
        newcavelevel(tmp);
    positionplayer();
    draws(0, MAXX, 0, MAXY);
    bot_linex();
}


/*
 * function to process a potion 
 */
static opotion(pot)
    int             pot;
{
    lprcat("\nDo you (d) drink it, (t) take it");
    iopts();
    while (1)
        switch (ttgetch())
        {
        case '\33':
        case 'i':
            ignore();
            return;

        case 'd':
            lprcat("drink\n");
            forget();   /* destroy potion  */
            quaffpotion(pot, TRUE);
            return;

        case 't':
            lprcat("take\n");
            if (take(OPOTION, pot) == 0)
                forget();
            return;
        };
}

/*
 * function to drink a potion 
 *
 * Also used to perform the action of a potion without quaffing a potion (see
 * invisible capability when drinking from a fountain). 
 */
quaffpotion(pot, set_known)
    int             pot;
    int             set_known;
{
    register int    i, j, k;

    /* check for within bounds */
    if (pot < 0 || pot >= MAXPOTION)
        return;

    /*
     * if player is to know this potion (really quaffing one), make it
     * known 
     */
    if (set_known)
        potionname[pot][0] = ' ';

    switch (pot)
    {
    case 0:
        lprcat("\nYou fall asleep. . .");
        i = rnd(11) - (c[CONSTITUTION] >> 2) + 2;
        while (--i > 0)
        {
            parse2();
            nap(1000);
        }
        cursors();
        lprcat("\nYou woke up!");
        return;

    case 1:
        lprcat("\nYou feel better");
        if (c[HP] == c[HPMAX])
            raisemhp(1);
        else
        if ((c[HP] += rnd(20) + 20 + c[LEVEL]) > c[HPMAX])
            c[HP] = c[HPMAX];
        break;

    case 2:
        lprcat("\nSuddenly, you feel much more skillful!");
        raiselevel();
        raisemhp(1);
        return;

    case 3:
        lprcat("\nYou feel strange for a moment");
        c[rund(6)]++;
        break;

    case 4:
        lprcat("\nYou feel more self confident!");
        c[WISDOM] += rnd(2);
        break;

    case 5:
        lprcat("\nWow!  You feel great!");
        if (c[STRENGTH] < 12)
            c[STRENGTH] = 12;
        else
            c[STRENGTH]++;
        break;

    case 6:
        lprcat("\nYour charm went up by one!");
        c[CHARISMA]++;
        break;

    case 7:
        lprcat("\nYou become dizzy!");
        if (--c[STRENGTH] < 3)
            c[STRENGTH] = 3;
        break;

    case 8:
        lprcat("\nYour intelligence went up by one!");
        c[INTELLIGENCE]++;
        break;

    case 9:
        lprcat("\nYou sense the presence of objects!");
        nap(1000);
        if (c[BLINDCOUNT])
            return;
        for (i = 0; i < MAXY; i++)
            for (j = 0; j < MAXX; j++)
                switch (item[j][i])
                    {
                    case OPLATE:
                    case OCHAIN:
                    case OLEATHER:
                    case ORING:
                    case OSTUDLEATHER:
                    case OSPLINT:
                    case OPLATEARMOR:
                    case OSSPLATE:
                    case OSHIELD:
                    case OSWORDofSLASHING:
                    case OHAMMER:
                    case OSWORD:
                    case O2SWORD:
                    case OSPEAR:
                    case ODAGGER:
                    case OBATTLEAXE:
                    case OLONGSWORD:
                    case OFLAIL:
                    case OLANCE:
                    case ORINGOFEXTRA:
                    case OREGENRING:
                    case OPROTRING:
                    case OENERGYRING:
                    case ODEXRING:
                    case OSTRRING:
                    case OCLEVERRING:
                    case ODAMRING:
                    case OBELT:
                    case OSCROLL:
                    case OPOTION:
                    case OBOOK:
                    case OCHEST:
                    case OAMULET:
                    case OORBOFDRAGON:
                    case OSPIRITSCARAB:
                    case OCUBEofUNDEAD:
                    case ONOTHEFT:
                    case OCOOKIE:
                        know[j][i] = HAVESEEN;
                        show1cell(j, i);
                        break;
                    }
        showplayer();
        return;

    case 10:        /* monster detection */
        lprcat("\nYou detect the presence of monsters!");
        nap(1000);
        if (c[BLINDCOUNT])
            return;
        for (i = 0; i < MAXY; i++)
            for (j = 0; j < MAXX; j++)
                if (mitem[j][i] && (monstnamelist[mitem[j][i]] != floorc))
                {
                    know[j][i] = HAVESEEN;
                    show1cell(j, i);
                }
        return;

    case 11:
        lprcat("\nYou stagger for a moment . .");
        for (i = 0; i < MAXY; i++)
            for (j = 0; j < MAXX; j++)
                know[j][i] = 0;
        nap(1000);
        draws(0, MAXX, 0, MAXY);    /* potion of forgetfulness */
        return;

    case 12:
        lprcat("\nThis potion has no taste to it");
        return;

    case 13:
        lprcat("\nYou can't see anything!");    /* blindness */
        c[BLINDCOUNT] += 500;
        return;

    case 14:
        lprcat("\nYou feel confused");
        c[CONFUSE] += 20 + rnd(9);
        return;

    case 15:
        lprcat("\nWOW!!!  You feel Super-fantastic!!!");
        if (c[HERO] == 0)
            for (i = 0; i < 6; i++)
                c[i] += 11;
        c[HERO] += 250;
        break;

    case 16:
        lprcat("\nYou have a greater intestinal constitude!");
        c[CONSTITUTION]++;
        break;

    case 17:
        lprcat("\nYou now have incredibly bulging muscles!!!");
        if (c[GIANTSTR] == 0)
            c[STREXTRA] += 21;
        c[GIANTSTR] += 700;
        break;

    case 18:
        lprcat("\nYou feel a chill run up your spine!");
        c[FIRERESISTANCE] += 1000;
        break;

    case 19:
        lprcat("\nYou feel greedy . . .");
        nap(1000);
        if (c[BLINDCOUNT])
            return;
        for (i = 0; i < MAXY; i++)
            for (j = 0; j < MAXX; j++)
            {
                k = item[j][i];
                if ((k == ODIAMOND)  ||
                    (k == ORUBY)     ||
                    (k == OEMERALD)  ||
                    (k == OMAXGOLD)  ||
                    (k == OSAPPHIRE) ||
                    (k == OLARNEYE)  ||
                    (k == OGOLDPILE))
                {
                    know[j][i] = HAVESEEN;
                    show1cell(j, i);
                }
            }
        showplayer();
        return;

    case 20:
        c[HP] = c[HPMAX];
        break;      /* instant healing */

    case 21:
        lprcat("\nYou don't seem to be affected");
        return;     /* cure dianthroritis */

    case 22:
        lprcat("\nYou feel a sickness engulf you"); /* poison */
        c[HALFDAM] += 200 + rnd(200);
        return;

    case 23:
        lprcat("\nYou feel your vision sharpen");   /* see invisible */
        c[SEEINVISIBLE] += rnd(1000) + 400;
        monstnamelist[INVISIBLESTALKER] = 'I';
        return;
    };
    bottomline();       /* show new stats      */
    return;
}


/*
 * function to process a magic scroll 
 */
static oscroll(typ)
    int             typ;
{
    lprcat("\nDo you ");
    if (c[BLINDCOUNT] == 0)
        lprcat("(r) read it, ");
    lprcat("(t) take it");
    iopts();
    while (1)
        switch (ttgetch())
        {
        case '\33':
        case 'i':
            ignore();
            return;

        case 'r':
            if (c[BLINDCOUNT])
                break;
            lprcat("read");
            forget();
            if (typ == 2 || typ == 15)
            {
                show1cell(playerx, playery);
                cursors();
            }
             /* destroy it  */ read_scroll(typ);
            return;

        case 't':
            lprcat("take");
            if (take(OSCROLL, typ) == 0)
                forget();   /* destroy it  */
            return;
        };
}

/*
 * data for the function to read a scroll 
 */
static int   xh, yh, yl, xl;
static char  curse[] = {BLINDCOUNT, CONFUSE, AGGRAVATE, HASTEMONST, ITCHING,
                        LAUGHING, DRAINSTRENGTH, CLUMSINESS, INFEEBLEMENT, 
                        HALFDAM};
static char  exten[] = {PROTECTIONTIME, DEXCOUNT, STRCOUNT, CHARMCOUNT,
                        INVISIBILITY, CANCELLATION, HASTESELF, GLOBE,
                        SCAREMONST, HOLDMONST, TIMESTOP};
static char  time_change[] = {HASTESELF, HERO, ALTPRO, PROTECTIONTIME, DEXCOUNT,
                              STRCOUNT, GIANTSTR, CHARMCOUNT, INVISIBILITY,
                              CANCELLATION,HASTESELF, AGGRAVATE, SCAREMONST,
                              STEALTH, AWARENESS, HOLDMONST, HASTEMONST,
                              FIRERESISTANCE, GLOBE, SPIRITPRO, UNDEADPRO,
                              HALFDAM, SEEINVISIBLE, ITCHING, CLUMSINESS, WTW};
/*
 * function to adjust time when time warping and taking courses in school
 */
adjtime(tim)
    register long   tim;
{
    register int    j;
    for (j = 0; j < 26; j++)/* adjust time related parameters */
        if (c[time_change[j]])
            if ((c[time_change[j]] -= tim) < 1)
                c[time_change[j]] = 1;
    regen();
}

/*
 * function to read a scroll 
 */
read_scroll(typ)
    int             typ;
{
    register int    i, j;
    if (typ < 0 || typ >= MAXSCROLL)
        return;     /* be sure we are within bounds */
    scrollname[typ][0] = ' ';
    switch (typ)
    {
    case 0:
        lprcat("\nYour armor glows for a moment");
        enchantarmor();
        return;

    case 1:
        lprcat("\nYour weapon glows for a moment");
        enchweapon();
        return;     /* enchant weapon */

    case 2:
        lprcat("\nYou have been granted enlightenment!");
        yh = min(playery + 7, MAXY);
        xh = min(playerx + 25, MAXX);
        yl = max(playery - 7, 0);
        xl = max(playerx - 25, 0);
        for (i = yl; i < yh; i++)
            for (j = xl; j < xh; j++)
                know[j][i] = KNOWALL;
        draws(xl, xh, yl, yh);
        return;

    case 3:
        lprcat("\nThis scroll seems to be blank");
        return;

    case 4:
        createmonster(makemonst(level + 1));
        return;     /* this one creates a monster  */

    case 5:
        something(level);   /* create artifact     */
        return;

    case 6:
        c[AGGRAVATE] += 800;
        return;     /* aggravate monsters */

    case 7:
        gtime += (i = rnd(1000) - 850); /* time warp */
        if (i >= 0)
            lprintf("\nYou went forward in time by %d mobuls", (long) ((i + 99) / 100));
        else
            lprintf("\nYou went backward in time by %d mobuls", (long) (-(i + 99) / 100));
        adjtime((long) i);  /* adjust time for time warping */
        return;

    case 8:
        oteleport(0);
        return;     /* teleportation */

    case 9:
        c[AWARENESS] += 1800;
        return;     /* expanded awareness   */

    case 10:
        c[HASTEMONST] += rnd(55) + 12;
        return;     /* haste monster */

    case 11:
        for (i = 0; i < MAXY; i++)
            for (j = 0; j < MAXX; j++)
                if (mitem[j][i])
                    hitp[j][i] = monster[mitem[j][i]].hitpoints;
        return;     /* monster healing */
    case 12:
        c[SPIRITPRO] += 300 + rnd(200);
        bottomline();
        return;     /* spirit protection */

    case 13:
        c[UNDEADPRO] += 300 + rnd(200);
        bottomline();
        return;     /* undead protection */

    case 14:
        c[STEALTH] += 250 + rnd(250);
        bottomline();
        return;     /* stealth */

    case 15:
        lprcat("\nYou have been granted enlightenment!");   /* magic mapping */
        for (i = 0; i < MAXY; i++)
            for (j = 0; j < MAXX; j++)
                know[j][i] = KNOWALL;
        draws(0, MAXX, 0, MAXY);
        return;

    case 16:
        c[HOLDMONST] += 30;
        bottomline();
        return;     /* hold monster */

    case 17:
        for (i = 0; i < 26; i++)    /* gem perfection */
            switch (iven[i])
            {
            case ODIAMOND:
            case ORUBY:
            case OEMERALD:
            case OSAPPHIRE:
                j = ivenarg[i];
                j &= 255;
                j <<= 1;
                if (j > 255)
                    j = 255;    /* double value */
                ivenarg[i] = j;
                break;
            }
        break;

    case 18:
        for (i = 0; i < 11; i++)
            c[exten[i]] <<= 1;  /* spell extension */
        break;

    case 19:
        for (i = 0; i < 26; i++)    /* identify */
        {
            if (iven[i] == OPOTION)
                potionname[ivenarg[i]][0] = ' ';
            if (iven[i] == OSCROLL)
                scrollname[ivenarg[i]][0] = ' ';
        }
        break;

    case 20:
        for (i = 0; i < 10; i++)    /* remove curse */
            if (c[curse[i]])
                c[curse[i]] = 1;
        break;

    case 21:
        annihilate();
        break;      /* scroll of annihilation */

    case 22:
        godirect(22, 150, "The ray hits the %s", 0, ' ');   /* pulverization */
        break;
    case 23:
        c[LIFEPROT]++;
        break;      /* life protection */
    };
}

static opit()
{
    register int    i;
    if (rnd(101) < 81)
        if (rnd(70) > 9 * c[DEXTERITY] - packweight() || rnd(101) < 5)
            if (level == MAXLEVEL - 1)
                obottomless();
            else
            if (level == MAXLEVEL + MAXVLEVEL - 1)
                obottomless();
            else
            {
                if (rnd(101) < 20)
                {
                    i = 0;
                    lprcat("\nYou fell into a pit!  Your fall is cushioned by an unknown force\n");
                } else
                {
                    i = rnd(level * 3 + 3);
                    lprintf("\nYou fell into a pit!  You suffer %d hit points damage", (long) i);
                    lastnum = 261;  /* if he dies scoreboard
                             * will say so */
                }
                losehp(i);
                nap(2000);
                newcavelevel(level + 1);
                draws(0, MAXX, 0, MAXY);
            }
}

static obottomless()
{
    lprcat("\nYou fell into a bottomless pit!");
    beep();
    nap(3000);
    died(262);
}

static ostatue()
{
}

static omirror()
{
}

static obook()
{
    lprcat("\nDo you ");
    if (c[BLINDCOUNT] == 0)
        lprcat("(r) read it, ");
    lprcat("(t) take it");
    iopts();
    while (1)
        switch (ttgetch())
        {
        case '\33':
        case 'i':
            ignore();
            return;

        case 'r':
            if (c[BLINDCOUNT])
                break;
            lprcat("read");
             /* no more book */ readbook(iarg[playerx][playery]);
            forget();
            return;

        case 't':
            lprcat("take");
            if (take(OBOOK, iarg[playerx][playery]) == 0)
                forget();   /* no more book */
            return;
        };
}

/*
 * function to read a book 
 */
readbook(lev)
    register int    lev;
{
    register int    i, tmp;
    if (lev <= 3)
        i = rund((tmp = splev[lev]) ? tmp : 1);
    else
        i = rnd((tmp = splev[lev] - 9) ? tmp : 1) + 9;
    spelknow[i] = 1;
    lprintf("\nSpell \"%s\":  %s\n%s", spelcode[i], spelname[i], speldescript[i]);
    if (rnd(10) == 4)
    {
        lprcat("\nYour int went up by one!");
        c[INTELLIGENCE]++;
        bottomline();
    }
}

static ocookie()
{
    char           *p;
    lprcat("\nDo you (e) eat it, (t) take it");
    iopts();
    while (1)
        switch (ttgetch())
        {
        case '\33':
        case 'i':
            ignore();
            return;

        case 'e':
            lprcat("eat");
            forget();   /* no more cookie */
            outfortune();
            return;

        case 't':
            lprcat("take");
            if (take(OCOOKIE, 0) == 0)
                forget();   /* no more book */
            return;
        };
}

/*
 * routine to pick up some gold -- if arg==OMAXGOLD then the pile is worth
 * 100* the argument
 */
static ogold(arg)
    int             arg;
{
    register long   i;
    i = iarg[playerx][playery];
    if (arg == OMAXGOLD)
        i *= 100;
    else
    if (arg == OKGOLD)
        i *= 1000;
    else
    if (arg == ODGOLD)
        i *= 10;
    lprintf("\nIt is worth %d!", (long) i);
    c[GOLD] += i;
    bottomgold();
    item[playerx][playery] = know[playerx][playery] = 0;    /* destroy gold    */
}

ohome()
{
    register int    i;
    nosignal = 1;       /* disable signals */
    for (i = 0; i < 26; i++)
        if (iven[i] == OPOTION)
            if (ivenarg[i] == 21)
            {
                iven[i] = 0;    /* remove the potion of cure
                         * dianthroritis from
                         * inventory */
                clear();
                lprcat("Congratulations.  You found a potion of cure dianthroritis.\n");
                lprcat("\nFrankly, No one thought you could do it.  Boy!  Did you surprise them!\n");
                if (gtime > TIMELIMIT)
                {
                    lprcat("\nThe doctor has the sad duty to inform you that your daughter died");
                    lprcat("\nbefore your return.  There was nothing he could do without the potion.\n");
                    nap(5000);
                    died(269);
                } else
                {
                    lprcat("\nThe doctor is now administering the potion, and in a few moments\n");
                    lprcat("your daughter should be well on her way to recovery.\n");
                    nap(6000);
                    lprcat("\nThe potion is");
                    nap(3000);
                    lprcat(" working!  The doctor thinks that\n");
                    lprcat("your daughter will recover in a few days.  Congratulations!\n");
                    beep();
                    nap(5000);
                    died(263);
                }
            }
    while (1)
    {
        clear();
        lprintf("Welcome home %s.  Latest word from the doctor is not good.\n", logname);

        if (gtime > TIMELIMIT)
        {
            lprcat("\nThe doctor has the sad duty to inform you that your daughter died!\n");
            lprcat("You didn't make it in time.  There was nothing he could do without the potion.\n");
            nap(5000);
            died(269);
        }
        lprcat("\nThe diagnosis is confirmed as dianthroritis.  He guesses that\n");
        lprintf("your daughter has only %d mobuls left in this world.  It's up to you,\n", (long) ((TIMELIMIT - gtime + 99) / 100));
        lprintf("%s, to find the only hope for your daughter, the very rare\n", logname);
        lprcat("potion of cure dianthroritis.  It is rumored that only deep in the\n");
        lprcat("depths of the caves can this potion be found.\n\n\n");
        lprcat("\n     ----- press ");
        standout("return");
        lprcat(" to continue, ");
        standout("escape");
        lprcat(" to leave ----- ");
        i = ttgetch();
        while (i != '\33' && i != '\n')
            i = ttgetch();
        if (i == '\33')
        {
            drawscreen();
            nosignal = 0;   /* enable signals */
            return;
        }
    }
}

/* routine to save program space   */
iopts()
{
    lprcat(", or (i) ignore it? ");
}
ignore()
{
    lprcat("ignore\n");
}

/*
 * For prompt mode, prompt for entering a building.
 */
static prompt_enter()
{
    char            i;

    lprcat("\nDo you (g) go inside, or (i) stay here? ");
    i = 0;
    while ((i != 'g') && (i != 'i') && (i != '\33'))
        i = ttgetch();
    if (i == 'g')
        enter();
    else
        lprcat(" stay here");
}

/*
 * For prompt mode, prompt for climbing up/down the volcanic shaft. 
 *
 * Takes one parameter: if it is negative, going down the shaft, otherwise,
 * going up the shaft. 
 */
static prompt_volshaft(dir)
    int             dir;
{
    char            i;

    lprcat("\nDo you (c) climb ");
    if (dir > 0)
        lprcat("up");
    else
        lprcat("down");
    iopts();

    i = 0;
    while ((i != 'c') && (i != 'i') && (i != '\33'))
        i = ttgetch();

    if ((i == '\33') || (i == 'i'))
    {
        ignore();
        return;
    }
    if (dir > 0)
        act_up_shaft();
    else
        act_down_shaft();
}

static o_open_door()
{
    char            i;
    lprcat("\nDo you (c) close it");
    iopts();
    i = 0;
    while ((i != 'c') && (i != 'i') && (i != '\33'))
        i = ttgetch();
    if ((i == '\33') || (i == 'i'))
    {
        ignore();
        return;
    }
    lprcat("close");
    forget();
    item[playerx][playery] = OCLOSEDDOOR;
    iarg[playerx][playery] = 0;
    playerx = lastpx;
    playery = lastpy;
}

static o_closed_door()
{
    char            i;
    lprcat("\nDo you (o) try to open it");
    iopts();
    i = 0;
    while ((i != 'o') && (i != 'i') && (i != '\33'))
        i = ttgetch();
    if ((i == '\33') || (i == 'i'))
    {
        ignore();
        playerx = lastpx;
        playery = lastpy;
        return;
    } else
    {
        lprcat("open");
        /*
         * if he failed to open the door ... 
         */
        if (!act_open_door(playerx, playery))
        {
            playerx = lastpx;
            playery = lastpy;
        }
    }
}
