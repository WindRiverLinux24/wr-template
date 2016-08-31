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
