public class DiskUsage.Indicator : Wingpanel.Indicator {
    /* Our display widget, a composited icon */
    private Wingpanel.Widgets.OverlayIcon display_widget ;

    /* The main widget that is displayed in the popover */
    private Gtk.Grid main_widget ;

    private Gtk.ListBox listbox ;

    public Indicator () {
        /* Some information about the indicator */
        Object (
            code_name: "disk-usage-indicator", /* Unique name */
            description: ("A wingpanel indicator to show disk-usage.")
            ) ;
    }

    private void create_items() {
        listbox = new Gtk.ListBox () ;

        const ulong GB = (1024 * 1024) * 1024 ;

        Posix.statvfs buffer = Posix.statvfs () ;
        int size_home = Posix.statvfs_exec ("/home/linarcx/", out buffer) ;
        ulong total = (ulong) (buffer.f_blocks * buffer.f_frsize) / GB ;
        // ulong total = (ulong) (buffer.f_bsize * buffer.f_bavail) ;
        ulong available = (ulong) (buffer.f_bfree * buffer.f_frsize) / GB ;

        var row = new Gtk.ListBoxRow () ;
        row.height_request = 30 ;

        var lbl_name = new Gtk.Label ("Home:") ;
        lbl_name.set_margin_left (5) ;
        lbl_name.set_halign (Gtk.Align.START) ;

        var lbl_size = new Gtk.Label (total.to_string () + " / " + available.to_string ()) ;
        // lbl_size.set_margin_right (5) ;
        lbl_size.set_halign (Gtk.Align.END) ;

        Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;
        box.pack_start (lbl_name, false, false, 0) ;
        box.pack_start (lbl_size, true, false, 0) ;

        row.add (box) ;
        row.show_all () ;
        listbox.insert (row, -1) ;
    }

    construct {
        /* Create a new composited icon */
        display_widget = new Wingpanel.Widgets.OverlayIcon ("drive-harddisk") ;

        create_items () ;

        var scrolled = new Gtk.ScrolledWindow (null, null) ;
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER ;
        scrolled.max_content_height = 500 ;
        scrolled.propagate_natural_height = true ;
        scrolled.add (listbox) ;

        var compositing_switch = new Wingpanel.Widgets.Switch ("Composited Icon") ;

        main_widget = new Gtk.Grid () ;
        main_widget.attach (scrolled, 0, 0) ;
        main_widget.attach (new Wingpanel.Widgets.Separator (), 0, 1) ;
        main_widget.attach (compositing_switch, 0, 2) ;

        /* Indicator should be visible at startup */
        this.visible = true ;

        compositing_switch.notify["active"].connect (() => {
            /* If the switch is enabled set the icon name of the icon that should be drawn on top of the other one, if not hide the top icon. */
            display_widget.set_overlay_icon_name (compositing_switch.active ? "network-vpn-lock-symbolic" : "") ;
        }) ;
    }

    /* This method is called to get the widget that is displayed in the panel */
    public override Gtk.Widget get_display_widget() {
        return display_widget ;
    }

    /* This method is called to get the widget that is displayed in the popover */
    public override Gtk.Widget ? get_widget () {
        return main_widget ;
    }

    /* This method is called when the indicator popover opened */
    public override void opened() {
        /* Use this method to get some extra information while displaying the indicator */
    }

    /* This method is called when the indicator popover closed */
    public override void closed() {
        /* Your stuff isn't shown anymore, now you can free some RAM, stop timers or anything else... */
    }

}

/*
 * This method is called once after your plugin has been loaded.
 * Create and return your indicator here if it should be displayed on the current server.
 */
public Wingpanel.Indicator ? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    /* A small message for debugging reasons */
    debug ("Activating DiskUsage Indicator") ;

    /* Check which server has loaded the plugin */
    if( server_type != Wingpanel.IndicatorManager.ServerType.SESSION ){
        /* We want to display our sample indicator only in the "normal" session, not on the login screen, so stop here! */
        return null ;
    }

    /* Create the indicator */
    var indicator = new DiskUsage.Indicator () ;

    /* Return the newly created indicator */
    return indicator ;
}


// var hide_button = new Gtk.ModelButton () ;
// hide_button.text = "Hide me!" ;

// hide_button.clicked.connect (() => {
// this.visible = false ;

// Timeout.add (2000, () => {
// this.visible = true ;
// return false ;
// }) ;
// }) ;
