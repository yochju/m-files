def ranksarray(rank):
    '''Returns a Fortran rank specification suffix.

    Args:
        rank (int): Rank of the object (must be >= 0).

    Returns:
        str: Rank specification suffix (e.g. (:)) or empty string for rank = 0.
    '''
    if rank == 0:
        return ''
    else:
        return 'dimension(' + ','.join([':'] * rank) + '),'
