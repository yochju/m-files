def compREAL(v):
    ''' compares v to a 'REAL64' and 'REAL32

    Args:
        v (string): some arbitrary string

    Returns:
        d if v is equal to REAL64, s if v is equal to REAL32 and '' else
    '''
    if v == 'REAL64':
        return 'd'
    elif v == 'REAL32':
        return 's'
    else:
        return ''
