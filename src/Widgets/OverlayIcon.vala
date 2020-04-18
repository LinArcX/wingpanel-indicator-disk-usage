public class DiskUsage.OverlayIcon : Gtk.Overlay {
    private Gtk.Image main_image ;
    private Gtk.Image overlay_image ;

    public OverlayIcon (string icon_name) {
        set_main_icon_name (icon_name) ;
    }

    public OverlayIcon.from_pixbuf (Gdk.Pixbuf pixbuf) {
        set_main_pixbuf (pixbuf) ;
    }

    construct {
        main_image = new Gtk.Image () ;
        main_image.icon_size = 24 ;
        main_image.pixel_size = 24 ;

        overlay_image = new Gtk.Image () ;
        overlay_image.icon_size = 16 ;
        overlay_image.pixel_size = 16 ;
        // overlay_image.margin_top = 5 ;
        overlay_image.set_valign (Gtk.Align.END) ;

        add (main_image) ;
        add_overlay (overlay_image) ;
    }

    public void set_main_pixbuf(Gdk.Pixbuf ? pixbuf) {
        main_image.set_from_pixbuf (pixbuf) ;
    }

    public Gdk.Pixbuf ? get_main_pixbuf () {
        return main_image.get_pixbuf () ;
    }

    public void set_overlay_pixbuf(Gdk.Pixbuf ? pixbuf) {
        overlay_image.set_from_pixbuf (pixbuf) ;
    }

    public Gdk.Pixbuf ? get_overlay_pixbuf () {
        return overlay_image.get_pixbuf () ;
    }

    public void set_main_icon_name(string icon_name) {
        main_image.icon_name = icon_name ;
    }

    public string get_main_icon_name() {
        return main_image.icon_name ;
    }

    public void set_overlay_icon_name(string icon_name) {
        overlay_image.icon_name = icon_name ;
    }

    public string get_overlay_icon_name() {
        return overlay_image.icon_name ;
    }

    public Gtk.Image get_main_image() {
        return main_image ;
    }

    public Gtk.Image get_overlay_image() {
        return overlay_image ;
    }

}
