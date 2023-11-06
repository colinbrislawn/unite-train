def get_mem_mb(wildcards, attempt):
    return (100 + attempt * 40) * 1000
    #      ^100gb base, then 40gb more each time
