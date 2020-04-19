public class DiskUsage.Indicator : Wingpanel.Indicator {
    bool _is_warning = false ;
    bool _is_critical = false ;
    bool _show_badge_icons = false ;
    const ulong _GB = (1024 * 1024) * 1024 ;

    private Gtk.Grid _main_grid ;
    private DiskUsage.OverlayIcon _display_widget ;
    private GLib.Settings _settings { get ; set ; }
    private Gtk.TreeView _tree_view { get ; set ; }
    private Gtk.ListStore _list_store { get ; set ; }

    enum Column {
        PARTITION,
        TOTAL,
        AVAILABLE
    }

    public Indicator () {
        Object (
            code_name: "disk-usage-indicator", /* Unique name */
            description: ("A wingpanel indicator to show disk-usage.")
            ) ;
    }

    private void CheckBadges() {
        if( _show_badge_icons ){
            if( _is_critical ){
                _display_widget.set_overlay_icon_name ("warning-symbolic") ;
            }
            if( _is_warning ){
                _display_widget.set_overlay_icon_name ("dialog-warning") ;
            }
        } else {
            _display_widget.set_overlay_icon_name ("") ;
        }
    }

    string[] ListOfMountedDevices() {
        string[] _mounted_devices = {} ;
        File _file = File.new_for_path ("/proc/mounts") ;

        try {
            string _line ;
            FileInputStream _fis = _file.read () ;
            DataInputStream _dis = new DataInputStream (_fis) ;

            while((_line = _dis.read_line ()) != null ){
                if( !_line.contains ("tmpfs") &&
                    !_line.contains ("cgroup") &&
                    !_line.contains ("sysfs") &&
                    !_line.contains ("devpts") &&
                    !_line.contains ("securityfs") &&
                    !_line.contains ("proc")){
                    _mounted_devices += _line.split (" ")[1] ;
                }
            }
        } catch ( Error e ) {
            print ("Error: %s\n", e.message) ;
        }
        return _mounted_devices ;
    }

    private void set_badges(ulong total, ulong available) {
        if( available >= total / 10 && available <= total / 4 ){
            _is_warning = true ;
            if( _show_badge_icons ){
                _display_widget.set_overlay_icon_name ("dialog-warning") ;
            }
        }
        if( available < total / 10 ){
            _is_critical = true ;
            if( _show_badge_icons ){
                _display_widget.set_overlay_icon_name ("warning-symbolic") ;
            }
        }
    }

    private void GenerateSetListModel(string[] items) {
        Gtk.TreeIter iter ;
        for( int i = 0 ; i < items.length ; i++ ){
            Posix.statvfs buffer = Posix.statvfs () ;
            Posix.statvfs_exec (items[i], out buffer) ;
            ulong total = (ulong) (buffer.f_blocks * buffer.f_frsize) / _GB ;
            ulong available = (ulong) (buffer.f_bfree * buffer.f_frsize) / _GB ;

            set_badges (total, available) ;

            _list_store.append (out iter) ;
            _list_store.set (iter,
                             Column.PARTITION, items[i],
                             Column.TOTAL, total.to_string (),
                             Column.AVAILABLE, available.to_string ()) ;
        }
        _tree_view.set_model (_list_store) ;
    }

    public void UpdateTreeView() {
        _list_store.clear () ;
        string[] mounted_devices = ListOfMountedDevices () ;
        GenerateSetListModel (mounted_devices) ;
    }

    construct {
        _settings = new GLib.Settings ("com.github.linarcx.wingpanel.indicator-disk-usage") ;
        _display_widget = new DiskUsage.OverlayIcon ("drive-harddisk") ;
        _show_badge_icons = _settings.get_boolean ("show-badge-icons") ;

        _tree_view = new Gtk.TreeView () ;
        _list_store = new Gtk.ListStore (3, typeof (string), typeof (string), typeof (string)) ;

        string[] mounted_devices = ListOfMountedDevices () ;
        GenerateSetListModel (mounted_devices) ;

        /*columns*/
        Gtk.TreeViewColumn col_partition = new Gtk.TreeViewColumn.with_attributes ("PARTITION", new Gtk.CellRendererText (), "text", Column.PARTITION, null) ;
        _tree_view.insert_column (col_partition, -1) ;

        var col_total = new Gtk.TreeViewColumn.with_attributes ("TOTAL", new Gtk.CellRendererText (), "text", Column.TOTAL, null) ;
        col_total.set_clickable (true) ;
        Gtk.Label m_label = new Gtk.Label.with_mnemonic ("File") ;
        m_label.set_visible (true) ;
        _tree_view.insert_column (col_total, -1) ;

        Gtk.TreeViewColumn col_available = new Gtk.TreeViewColumn.with_attributes ("AVAILABLE", new Gtk.CellRendererText (), "text", Column.AVAILABLE, null) ;
        _tree_view.insert_column (col_available, -1) ;

        var scrolled = new Gtk.ScrolledWindow (null, null) ;
        scrolled.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC) ;
        scrolled.min_content_height = 150 ;
        scrolled.max_content_height = 300 ;
        scrolled.add (_tree_view) ;

        Wingpanel.Widgets.Switch _switch = new Wingpanel.Widgets.Switch ("Show badge Icons") ;
        _switch.notify["active"].connect (() => {
            if( _switch.active ){
                _settings.set_boolean ("show-badge-icons", true) ;
                _show_badge_icons = true ;
            } else {
                _settings.set_boolean ("show-badge-icons", false) ;
                _show_badge_icons = false ;
            }
            CheckBadges () ;
        }) ;

        _main_grid = new Gtk.Grid () ;
        _main_grid.attach (scrolled, 0, 0) ;
        _main_grid.attach (new Wingpanel.Widgets.Separator (), 0, 1) ;
        _main_grid.attach (_switch, 0, 2) ;

        if( _show_badge_icons == true ){
            _switch.active = true ;
        } else {
            _switch.active = false ;
        }
        CheckBadges () ;

        this.visible = true ;
    }

    public override Gtk.Widget get_display_widget() {
        return _display_widget ;
    }

    public override Gtk.Widget ? get_widget () {
        UpdateTreeView () ;
        return _main_grid ;
    }

    public override void opened() {
        UpdateTreeView () ;
    }

    public override void closed() {
    }

}

public Wingpanel.Indicator ? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating DiskUsage Indicator") ;
    if( server_type != Wingpanel.IndicatorManager.ServerType.SESSION ){
        return null ;
    }
    var indicator = new DiskUsage.Indicator () ;
    return indicator ;
}
