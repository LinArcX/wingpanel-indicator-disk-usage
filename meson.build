project('com.github.linarcx.wingpanel.indicator-disk-usage', 'vala', 'c')

wingpanel_dep = dependency('wingpanel-2.0')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('granite'),
    dependency('gtk+-3.0'),
    meson.get_compiler('vala').find_library('posix'),
    wingpanel_dep
]

files = [
    'src/Main.vala',
    'src/Widgets/OverlayIcon.vala'
]

shared_module(
    meson.project_name(),
    files,
    dependencies: dependencies,
    install: true,
    #install_dir : wingpanel_dep.get_pkgconfig_variable('indicatorsdir')
    install_dir : '/usr/lib/wingpanel/'
)

subdir('data')

meson.add_install_script('meson/post_install.py')
