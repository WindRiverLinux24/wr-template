#
# Template helper and image override class
#
# Copyright (C) 2016 Wind River
#
# Purpose of this class is to intercept the image.bbclass inherit and add
# template process inclusion.
#

def wrlt_next_class(d, classname):
    """
    This function should be called w/ d and the name of this class (classname)

    It will find the next (in the path) version of this class, or return ""

    It allows a class in an early layer to include a class in a later layer.
    """

    idx = -1
    bbpath = d.getVar('BBPATH', True).split(':')

    # based on bb.data.inherits_class -- find the last inherit of this class
    val = d.getVar('__inherit_cache', False) or []
    needle = os.path.join('classes', '%s.bbclass' % classname)
    val.reverse()
    for v in val:
        if v.endswith(needle):
           layername = os.path.dirname(os.path.dirname(v))
           idx = bbpath.index(layername)
           break

    ret = bb.utils.which(":".join(bbpath[idx+1:]), 'classes/%s.bbclass' % classname) or ""

    return ret

inherit ${@wrlt_next_class(d, 'image')}

# The includes must always be -after- image.bbclass inherit
# because they may add or remove from the image variable
include ${WRTEMPLATE_CONF_WRIMAGE}
include ${WRTEMPLATE_CONF_WRIMAGE_MACH}
