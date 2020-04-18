public class DiskUsage.Indicator : Wingpanel.Indicator {
    string[] paths ;
    const ulong GB = (1024 * 1024) * 1024 ;

    /* Our display widget, a composited icon */
    private Wingpanel.Widgets.OverlayIcon display_widget ;

    /* The main widget that is displayed in the popover */
    private Gtk.Grid main_grid ;

    public Gtk.ListBox listbox ;
    public GLib.Settings settings ;
    public Gtk.ListBox lb_settings { get ; set ; }
    public Gtk.ModelButton settings_button ;

    public Indicator () {
        /* Some information about the indicator */
        Object (
            code_name: "disk-usage-indicator", /* Unique name */
            description: ("A wingpanel indicator to show disk-usage.")
            ) ;
    }

    private void dir_selected(Gtk.NativeDialog dialog, int response_id) {
        var dlg = dialog as Gtk.FileChooserNative ;

        switch( response_id ){
        case Gtk.ResponseType.ACCEPT:
            var file = dlg.get_file () ;
            var full_path = file.get_path () ;
            paths += full_path ;
            settings.set_strv ("paths", paths) ;
            break ;
        case Gtk.ResponseType.CANCEL:
            dlg.destroy () ;
            break ;
        }
        dlg.destroy () ;
    }

    public void open_dialog(Gtk.Dialog parent_window) {
        var dlg = new Gtk.FileChooserNative ("Select a file",
                                             parent_window,
                                             Gtk.FileChooserAction.SELECT_FOLDER,
                                             "_Open",
                                             "_Cancel") ;
        dlg.local_only = true ;
        dlg.modal = true ;
        dlg.response.connect (dir_selected) ;
        dlg.run () ;
    }

    private void create_items() {
        listbox = new Gtk.ListBox () ;

        if( paths.length == 0 ){
            print ("Empty!") ;
        } else {
            for( int i = 0 ; i < paths.length ; i++ ){
                Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;

                Posix.statvfs buffer = Posix.statvfs () ;
                int size_home = Posix.statvfs_exec (paths[i], out buffer) ;
                ulong total = (ulong) (buffer.f_blocks * buffer.f_frsize) / GB ;
                ulong available = (ulong) (buffer.f_bfree * buffer.f_frsize) / GB ;

                var row = new Gtk.ListBoxRow () ;
                row.height_request = 30 ;

                var lbl_name = new Gtk.Label (paths[i]) ;
                lbl_name.set_margin_left (15) ;
                lbl_name.set_halign (Gtk.Align.START) ;

                var lbl_size = new Gtk.Label (total.to_string () + " / " + available.to_string ()) ;
                // lbl_size.set_margin_right (5) ;
                lbl_size.set_halign (Gtk.Align.END) ;

                box.pack_start (lbl_name, false, false, 0) ;
                box.pack_start (lbl_size, true, false, 0) ;

                row.add (box) ;
                row.show_all () ;
                listbox.insert (row, -1) ;

            }
        }
    }

    private void generate_settings_listbox() {
        lb_settings = new Gtk.ListBox () ;
        if( paths.length == 0 ){
            print ("Empty!") ;
        } else {
            for( int i = 0 ; i < paths.length ; i++ ){

                Gtk.Box box_settings = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;

                var lbr_settings = new Gtk.ListBoxRow () ;
                lbr_settings.height_request = 30 ;

                var lbl_name = new Gtk.Label (paths[i]) ;
                lbl_name.set_margin_left (15) ;
                lbl_name.set_halign (Gtk.Align.START) ;

                box_settings.pack_start (lbl_name, false, false, 0) ;

                lbr_settings.add (box_settings) ;
                lbr_settings.show_all () ;
                lb_settings.insert (lbr_settings, -1) ;
            }
        }
    }

    public void open_settings_window() {
        var settings_dialog = new Gtk.Dialog () ;
        settings_dialog.deletable = false ;
        settings_dialog.resizable = false ;
        settings_dialog.default_width = 400 ;

        var content_area = settings_dialog.get_content_area () ;

        generate_settings_listbox () ;

        var apply_button = new Gtk.Button.with_label (("Add new path")) ;
        apply_button.width_request = 400 ;
        apply_button.halign = Gtk.Align.CENTER ;
        apply_button.get_style_context ().add_class ("suggested-action") ;
        apply_button.clicked.connect (() => {
            open_dialog (settings_dialog) ;
        }) ;

        content_area.pack_end (lb_settings) ;
        content_area.pack_end (new Wingpanel.Widgets.Separator ()) ;
        content_area.pack_end (apply_button) ;
        settings_dialog.show_all () ;
        settings_dialog.present () ;
    }

    construct {
        settings = new GLib.Settings ("com.github.linarcx.indicator-disk-usage") ;
        paths = settings.get_strv ("paths") ;

        /* Create a new composited icon */
        display_widget = new Wingpanel.Widgets.OverlayIcon ("drive-harddisk") ;

        create_items () ;

        var scrolled = new Gtk.ScrolledWindow (null, null) ;
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER ;
        scrolled.max_content_height = 500 ;
        scrolled.propagate_natural_height = true ;
        scrolled.add (listbox) ;

        settings_button = new Gtk.ModelButton () ;
        settings_button.text = ("Indicator Settings…") ;
        settings_button.clicked.connect (open_settings_window) ;

        var compositing_switch = new Wingpanel.Widgets.Switch ("Composited Icon") ;

        main_grid = new Gtk.Grid () ;
        main_grid.attach (scrolled, 0, 0) ;
        main_grid.attach (new Wingpanel.Widgets.Separator (), 0, 1) ;
        main_grid.attach (compositing_switch, 0, 2) ;
        main_grid.attach (settings_button, 0, 3) ;

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
        return main_grid ;
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
