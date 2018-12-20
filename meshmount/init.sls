{% from "meshmount/map.jinja" import meshmount with context %}

{% if salt['pillar.get']('meshmount:type', 'fuse') == 'fuse' %}
{% if salt['pillar.get']('meshmount:fuse_type', 'sshfs') == 'sshfs' %}
meshmount_packages:
  pkg.installed:
    - name: {{ meshmount.pkg_sshfs }}
    - pkgs:
      - {{ meshmount.pkg_sshfs }}
    - refresh: True
{% endif %}
{% elif salt['pillar.get']('meshmount:type', 'fuse') == 'nfs' %}
meshmount_packages:
  pkg.installed:
    - name: {{ meshmount.pkg_nfs }}
    - pkgs:
      - {{ meshmount.pkg_nfs }}
    - refresh: True
{% endif %}

{% for node in salt['pillar.get']('meshmount:nodes', []) %}
{% if node != grains['host']|lower %}
{{salt['pillar.get']('meshmount:path', '/srv/data')}}/{{node}}:
  mount.mounted:
{% if salt['pillar.get']('meshmount:type', 'fuse') == 'fuse' %}
    - device: {{salt['pillar.get']('meshmount:fuse_type', 'sshfs')}}#{{salt['pillar.get']('meshmount:user', 'root')}}@{{node}}:{{salt['pillar.get']('meshmount:path', '/srv/data')}}/{{node}}
    - fstype: {{salt['pillar.get']('meshmount:type', 'fuse')}}
{% elif salt['pillar.get']('meshmount:type', 'fuse') == 'nfs' %}
    - device: {{node}}:{{salt['pillar.get']('meshmount:path', '/srv/data')}}/{{node}}
    - fstype: {{salt['pillar.get']('meshmount:type', 'fuse')}}
{% elif salt['pillar.get']('meshmount:type', 'fuse') == 'cifs' %}
    - device: //{{node}}{{salt['pillar.get']('meshmount:path', '/srv/data')}}/{{node}}
    - fstype: {{salt['pillar.get']('meshmount:type', 'fuse')}}
{% endif %}
    - dump: 0
    - pass_num: 0
    - persist: True
    - mkmnt: True
{% if salt['pillar.get']('meshmount:opts', []) %}
    - opts:
{%- for opt in salt['pillar.get']('meshmount:opts', []) %}
      - {{opt}}
{%- endfor %}
{% endif %}
{% else %}
#Make the directory for host to export (not for the mount)
{{salt['pillar.get']('meshmount:path', '/srv/data')}}/{{node}}:
  file.directory:
    - makedirs: True
{% endif %}
{% endfor %}

# Create the /etc/exports to allow the others in
# nfs_export.present not available until Salt 2018.3
mesh_nfs_exports:
  file.managed:
    - name: /etc/exports
    - source: salt://meshmount/templates/exports.jinja
    - template: jinja

update_nfs:
  cmd.run:
    - name: '/usr/sbin/exportfs -ra'
    - onchanges:
      - file: mesh_nfs_exports
