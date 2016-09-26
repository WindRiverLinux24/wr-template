#
# banner class
#
# Purpose of this class is to allow a template to easily display banners
# to the user at template configuration time as well as standard build time.
#
# Copyright (C) 2016 Wind River Systems, Inc.
#
# Source code included in the tree for individual recipes is under the LICENSE
# stated in the associated recipe (.bb file) unless otherwise stated.
#
# The metadata is under the following license unless otherwise stated.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# We only want to display the banner -once- and when the build has started...
addhandler wrl_banner_eventhandler
wrl_banner_eventhandler[eventmask] = "bb.event.ParseStarted bb.event.BuildStarted"
python wrl_banner_eventhandler () {
    from bb import note, error, data

    # Banner format:
    #
    # CONFIG_BANNER display only at configure time
    # BANNER display each time the build system is run
    #
    #CONFIG_BANNER[path_to_template] = "..."
    #BANNER[path_to_template] = "..."
    #
    def write_banner_file(d, bannerfile, bannervar):
        import textwrap
        if bannerfile:
            fn = os.path.join(d.getVar('TOPDIR', True),bannerfile)
        else:
            fn = ""
        f = None
        banner_head = 0

        for flag in (d.getVarFlags(bannervar) or {}):
            if flag == "doc" or flag == "vardeps" or flag == "vardepsexp":
                continue
            banner = d.getVarFlag(bannervar, flag, True)
            if banner:
                if banner_head == 0:
                   banner_head = 1
                   bb.plain('----------------------------------------------------------------------')
                else:
                   bb.plain('')
                bb.plain(textwrap.fill(banner,70))

            if banner and fn:
                try:
                    if f is None:
                        f = open(fn, "w")
                    else:
                        f.write('\n')
                    f.write(textwrap.fill(banner,70))
                    f.write('\n')
                except IOError as ex:
                    bb.error("Unable to create banner file: %s: %s" % (ex.filename, ex.args[1]))
                    f = None
        if banner_head == 1:
            bb.plain('----------------------------------------------------------------------')

        if f != None:
            f.close()

    if bb.event.getName(e) == "ParseStarted":
        write_banner_file(e.data, "README_config_notes", "CONFIG_BANNER")

    if bb.event.getName(e) == "BuildStarted":
        write_banner_file(e.data, None, "BANNER")

}
