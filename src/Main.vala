public class DiskUsage.Indicator : Wingpanel.Indicator {
    public GLib.Settings settings ;
    private Gtk.Grid main_grid ;
    private Gtk.Image display_icon ;

    Gtk.ModelButton restart_button ;
    Gtk.ModelButton settings_button ;

    public Indicator () {
        Object (
            code_name: "indicator-disk-usage",
            display_name: ("disk-usage"),
            description: ("A wingpanel indicator to show disk-usage.")
            ) ;
    }

    construct {
        var gtk_settings = Gtk.Settings.get_default () ;
        settings = new GLib.Settings ("com.github.linarcx.indicator-disk-usage") ;

        display_icon = new Gtk.Image.from_icon_name ("drive-harddisk", Gtk.IconSize.LARGE_TOOLBAR) ;
        restart_button = new Gtk.ModelButton () ;
        restart_button.text = ("Restart Dock") ;

        settings_button = new Gtk.ModelButton () ;
        settings_button.text = ("Indicator Settings…") ;

        main_grid = new Gtk.Grid () ;
        // main_grid.attach (toggle_switch, 0, 0) ;
        main_grid.attach (new Wingpanel.Widgets.Separator (), 0, 1) ;
        if( settings.get_boolean ("button-show")){
            main_grid.attach (restart_button, 0, 2) ;
        }
        main_grid.attach (settings_button, 0, 3) ;

        this.visible = true ;
        connect_signals () ;
    }

    private void connect_signals() {
        restart_button.clicked.connect (() => {
            Posix.system ("pkill plank") ;
        }) ;

        settings_button.clicked.connect (open_settings_window) ;
    }

    public void open_settings_window() {
        var settings_dialog = new Gtk.Dialog () ;
        settings_dialog.resizable = false ;
        settings_dialog.deletable = false ;

        var content_area = settings_dialog.get_content_area () ;

        var show_restartbutton_switch = new Wingpanel.Widgets.Switch (("Show restart button on indicator"), settings.get_boolean ("button-show")) ;
        show_restartbutton_switch.notify["active"].connect (() => {
            if( show_restartbutton_switch.active ){
                settings.set_boolean ("button-show", true) ;
            } else {
                settings.set_boolean ("button-show", false) ;
            }
        }) ;

        var apply_button = new Gtk.Button.with_label (("Apply")) ;
        apply_button.halign = Gtk.Align.CENTER ;
        apply_button.get_style_context ().add_class ("suggested-action") ;
        apply_button.clicked.connect (() => {
            Posix.system ("pkill wingpanel") ;
        }) ;

        // content_area.add (restart_on_toggle_switch) ;
        content_area.add (show_restartbutton_switch) ;
        content_area.add (new Wingpanel.Widgets.Separator ()) ;
        content_area.add (apply_button) ;
        settings_dialog.show_all () ;
        settings_dialog.present () ;
    }

    public override Gtk.Widget get_display_widget() {
        return display_icon ;
    }

    public override Gtk.Widget ? get_widget () {
        if( main_grid == null ){
            main_grid = new Gtk.Grid () ;
            main_grid.set_orientation (Gtk.Orientation.VERTICAL) ;

            main_grid.show_all () ;
        }
        return main_grid ;
    }

    public override void opened() {
    }

    public override void closed() {
    }

}

public Wingpanel.Indicator ? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    // Temporal workarround for Greeter crash
    if( server_type != Wingpanel.IndicatorManager.ServerType.SESSION ){
        return null ;
    }

    debug ("Activating DiskUsage Indicator") ;
    var indicator = new DiskUsage.Indicator () ;
    return indicator ;
}
