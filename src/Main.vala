public class DiskUsage.Indicator : Wingpanel.Indicator {

    string[] paths ;
    bool is_warning = false ;
    bool is_critical = false ;
    bool show_badge_icons = false ;
    const ulong GB = (1024 * 1024) * 1024 ;

    /* Our display widget, a composited icon */
    private DiskUsage.OverlayIcon display_widget ;

    /* The main widget that is displayed in the popover */
    private Gtk.Grid main_grid ;
    public Gtk.ListBox lb_main ;
    public GLib.Settings settings { get ; set ; }
    private Wingpanel.Widgets.Switch _switch { get ; set ; }

    public Indicator () {
        /* Some information about the indicator */
        Object (
            code_name: "disk-usage-indicator", /* Unique name */
            description: ("A wingpanel indicator to show disk-usage.")
            ) ;
    }

    string[] list_of_all_mount_devices() {
        string[] lst_md = {} ;

        File file = File.new_for_path ("/proc/mounts") ;
        try {
            FileInputStream fis = file.read () ;
            DataInputStream dis = new DataInputStream (fis) ;
            string line ;

            while((line = dis.read_line ()) != null ){
                if( !line.contains ("tmpfs") &&
                    !line.contains ("cgroup") &&
                    !line.contains ("sysfs") &&
                    !line.contains ("devpts") &&
                    !line.contains ("securityfs") &&
                    !line.contains ("proc")){
                    lst_md += line.split (" ")[1] ;
                }
            }
        } catch ( Error e ) {
            print ("Error: %s\n", e.message) ;
        }
        return lst_md ;
    }

    private void generate_main_listbox() {
        lb_main = new Gtk.ListBox () ;

        if( paths.length == 0 ){
            print ("What's wrong with your system dude?!") ;
        } else {
            for( int i = 0 ; i < paths.length ; i++ ){
                Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;

                Posix.statvfs buffer = Posix.statvfs () ;
                Posix.statvfs_exec (paths[i], out buffer) ;
                ulong total = (ulong) (buffer.f_blocks * buffer.f_frsize) / GB ;
                ulong available = (ulong) (buffer.f_bfree * buffer.f_frsize) / GB ;

                var row = new Gtk.ListBoxRow () ;
                row.height_request = 30 ;

                var lbl_name = new Gtk.Label (paths[i]) ;
                lbl_name.set_margin_left (15) ;
                lbl_name.set_halign (Gtk.Align.START) ;

                var lbl_size_total = new Gtk.Label (total.to_string () + " GB " + " / ") ;
                var lbl_size_available = new Gtk.Label (available.to_string () + " GB ") ;
                lbl_size_available.set_halign (Gtk.Align.END) ;
                lbl_size_available.set_margin_right (15) ;

                if( available > total / 4 ){
                    lbl_size_available.override_color (Gtk.StateFlags.NORMAL, { 0, 0.90, 0.25, 1 }) ;
                }
                if( available >= total / 10 && available <= total / 4 ){
                    is_warning = true ;
                    lbl_size_available.override_color (Gtk.StateFlags.NORMAL, { 0.956, 0.815, 0.247, 0.7 }) ;
                    if( show_badge_icons ){
                        display_widget.set_overlay_icon_name ("dialog-warning") ;
                    }
                }
                if( available < total / 10 ){
                    is_critical = true ;
                    lbl_size_available.override_color (Gtk.StateFlags.NORMAL, { 0.850, 0.117, 0.094, 1 }) ;
                    if( show_badge_icons ){
                        display_widget.set_overlay_icon_name ("warning-symbolic") ;
                    }
                }
                box.pack_start (lbl_name, false, false, 0) ;
                box.pack_end (lbl_size_available, false, false, 0) ;
                box.pack_end (lbl_size_total, false, false, 0) ;

                row.add (box) ;
                row.show_all () ;
                lb_main.insert (row, -1) ;
            }
        }
    }

    construct {
        paths = list_of_all_mount_devices () ;

        settings = new GLib.Settings ("com.github.linarcx.wingpanel.indicator-disk-usage") ;
        show_badge_icons = settings.get_boolean ("show-badge-icons") ;

        /* Create a new composited icon */
        display_widget = new DiskUsage.OverlayIcon ("drive-harddisk") ;

        generate_main_listbox () ;

        var scrolled = new Gtk.ScrolledWindow (null, null) ;
        scrolled.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC) ;
        scrolled.min_content_height = 100 ;
        scrolled.max_content_height = 600 ;
        scrolled.add (lb_main) ;

        _switch = new Wingpanel.Widgets.Switch ("Show badge Icons") ;
        _switch.notify["active"].connect (() => {
            if( _switch.active ){
                settings.set_boolean ("show-badge-icons", true) ;
                show_badge_icons = true ;
            } else {
                settings.set_boolean ("show-badge-icons", false) ;
                show_badge_icons = false ;
            }
        }) ;

        main_grid = new Gtk.Grid () ;
        main_grid.attach (scrolled, 0, 0) ;
        main_grid.attach (new Wingpanel.Widgets.Separator (), 0, 1) ;
        main_grid.attach (_switch, 0, 2) ;

        /* Indicator should be visible at startup */
        this.visible = true ;
    }

    /* This method is called to get the widget that is displayed in the panel */
    public override Gtk.Widget get_display_widget() {
        return display_widget ;
    }

    /* This method is called to get the widget that is displayed in the popover */
    public override Gtk.Widget ? get_widget () {
        return main_grid ;
    }

    /* This method is called when the indicator popover opened */
    public override void opened() {
        /* Use this method to get some extra information while displaying the indicator */
        if( show_badge_icons == true ){
            _switch.active = true ;
        } else {
            _switch.active = false ;
        }
    }

    /* This method is called when the indicator popover closed */
    public override void closed() {
        /* Your stuff isn't shown anymore, now you can free some RAM, stop timers or anything else... */
        if( show_badge_icons ){
            /* If the switch is enabled set the icon name of the icon that should be drawn on top of the other one, if not hide the top icon. */
            if( is_critical ){
                display_widget.set_overlay_icon_name ("warning-symbolic") ;
            }
            if( is_warning ){
                display_widget.set_overlay_icon_name ("dialog-warning") ;
            }
        } else {
            display_widget.set_overlay_icon_name ("") ;
        }
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
