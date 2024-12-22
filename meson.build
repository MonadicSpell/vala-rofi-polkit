project(
  'vala_rofi_polkit',
  'vala',
  version: '1.0',
)

dependencies = [
  dependency('glib-2.0'),
  dependency('gio-2.0'),
  dependency('gobject-2.0'),
  dependency('polkit-gobject-1'),
  dependency('polkit-agent-1'),
]

add_project_arguments('-DPOLKIT_AGENT_I_KNOW_API_IS_SUBJECT_TO_CHANGE', language: 'c')

sources = files('main.vala')

executable('vala-polkit-forwarder',
  sources,
  dependencies: dependencies,
)
