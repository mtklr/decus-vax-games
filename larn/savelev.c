/* savelev.c */
#include "header.h"
#include "larndefs.h"

# ifdef MSDOS

extern int swapfd;      /* swap file file descriptor */

DISKBLOCK *
getfreediskblk()
{
    DISKBLOCK   *dp;

    for (dp = diskblks; dp; dp = dp->next)
        if (dp->level == FREEBLOCK)
            return dp;
    levelinfo();
    error("Can't find a free disk block ?\n");
}

RAMBLOCK *
getramblk(lev)
{
    RAMBLOCK    *rp, *orp;
    DISKBLOCK   *dp;
    long        otime;
    unsigned int    bytes;

    /* Check if the level is in memory already.
     */
    for (rp = ramblks; rp; rp = rp->next)
        if (rp->level == lev)
            return rp;

    /* Else grab the first available one.
     */
    for (rp = ramblks; rp; rp = rp->next)
        if (rp->level == FREEBLOCK)
            return rp;

    /* No ramblocks free, so swap out the oldest level
     */
    dp = getfreediskblk();

# ifdef ndef
warn("\nTrying to swap\n");
# endif

    /* Find the oldest level for swapping out.
     */
    otime = ramblks->gtime;
    orp = ramblks;
    for (rp = ramblks->next; rp; rp = rp->next) {
        if (rp->gtime < otime) {
            otime = rp->gtime;
            orp = rp;
        }
    }

    /* Send the oldest level out to disk.
     */
    if (lseek(swapfd, dp->fpos, 0) < 0)
        error("Can't seek to %ld\n", dp->fpos);

    bytes = sizeof rp->cell;
    if (write(swapfd, (char *) orp->cell, bytes) != bytes)
        error("Out of space writing swap file !\n");

    /* Update the level information
     */
    dp->level = orp->level;
    dp->gtime = orp->gtime;
    orp->level = FREEBLOCK;
# ifdef ndef
warn("Successful swap\n");
# endif
    return orp;
}


# endif

/*
 *  routine to save the present level into storage
 */
savelevel()
    {
    register struct cel *pcel;
    register char *pitem,*pknow,*pmitem;
    register short *phitp,*piarg;
    register struct cel *pecel;

# ifdef MSDOS
    RAMBLOCK    *rp;

    rp = getramblk(level);
    pcel = rp->cell;
    rp->gtime = gtime;
    rp->level = level;
# else
    pcel = &cell[level*MAXX*MAXY];  /* pointer to this level's cells */
# endif
    pecel = pcel + MAXX*MAXY;   /* pointer to past end of this level's cells */
    pitem=item[0]; piarg=iarg[0]; pknow=know[0]; pmitem=mitem[0]; phitp=hitp[0];
    while (pcel < pecel)
        {
        pcel->mitem  = *pmitem++;
        pcel->hitp   = *phitp++;
        pcel->item   = *pitem++;
        pcel->know   = *pknow++;
        pcel->iarg   = *piarg++;
        pcel++;
        }
    }


/*
 *  routine to restore a level from storage
 */
getlevel()
    {
    register struct cel *pcel;
    register char *pitem,*pknow,*pmitem;
    register short *phitp,*piarg;
    register struct cel *pecel;

# ifdef MSDOS
    RAMBLOCK    *rp;
    DISKBLOCK   *dp;
    unsigned int    bytes;

    /* Is the level in memory already ?
     */
    for (rp = ramblks; rp; rp = rp->next)
        if (rp->level == level)
            goto haverp;

    /* Is it on disk ?
     */
    for (dp = diskblks; dp; dp = dp->next)
        if (dp->level == level)
            break;
    if (dp == NULL) {
        levelinfo();
        error("Level %d is neither in memory nor on disk\n", level);
    }

    /* Make room for it and read it in.
     */
    rp = getramblk(level);
    if (lseek(swapfd, dp->fpos, 0) < 0)
        error("Can't seek to %ld\n", dp->fpos);
    bytes = sizeof rp->cell;
    if (read(swapfd, (char *) rp->cell, bytes) != bytes)
        error("Didn't read %u bytes\n", bytes);

    /* The disk space is available for future swaps.
     */
    dp->level = FREEBLOCK;
haverp:
    pcel = rp->cell;
    rp->level = FREEBLOCK;
# else
    pcel = &cell[level*MAXX*MAXY];  /* pointer to this level's cells */
# endif
    pecel = pcel + MAXX*MAXY;   /* pointer to past end of this level's cells */
    pitem=item[0]; piarg=iarg[0]; pknow=know[0]; pmitem=mitem[0]; phitp=hitp[0];
    while (pcel < pecel)
        {
        *pmitem++ = pcel->mitem;
        *phitp++ = pcel->hitp;
        *pitem++ = pcel->item;
        *pknow++ = pcel->know;
        *piarg++ = pcel->iarg;
        pcel++;
        }
    }
