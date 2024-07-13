def get_mem_mb(wildcards, attempt):
    return (60 + attempt * 40) * 1000
    #      ^(60+40)gb first, then 40gb more each time
