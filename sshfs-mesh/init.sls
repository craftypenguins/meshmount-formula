{% from "sshfs-mesh/map.jinja" import sshfs_mesh with context %}

{% if salt['pillar.get']('sshfs-mesh:type', 'fuse') == 'fuse' %}
{% if salt['pillar.get']('sshfs-mesh:fuse_type', 'sshfs') == 'sshfs' %}
sshfs_mesh_packages:
  pkg.installed:
    - name: {{ sshfs_mesh.pkg_sshfs }}
    - pkgs:
      - {{ sshfs_mesh.pkg_sshfs }}
    - refresh: True
{% endif %}
{% endif %}

{% if salt['pillar.get']('sshfs-mesh:type', 'fuse') == 'nfs' %}
sshfs_mesh_packages:
  pkg.installed:
    - name: {{ sshfs_mesh.pkg_nfs }}
    - pkgs:
      - {{ sshfs_mesh.pkg_nfs }}
    - refresh: True
{% endif %}

{% for node in salt['pillar.get']('sshfs-mesh:nodes', []) %}
{% if node != grains['id'] %}
{{salt['pillar.get']('sshfs-mesh:path', '/srv/data')}}/{{node}}:
  mount.mounted:
{% if salt['pillar.get']('sshfs-mesh:type', 'fuse') == 'fuse' %}
    - device: {{salt['pillar.get']('sshfs-mesh:fuse_type', 'sshfs')}}#{{salt['pillar.get']('sshfs-mesh:user', 'root')}}@{{node}}:{{salt['pillar.get']('sshfs-mesh:path', '/srv/data')}}/{{node}}
    - fstype: {{salt['pillar.get']('sshfs-mesh:type', 'fuse')}}
{% elif salt['pillar.get']('sshfs-mesh:type', 'fuse') == 'nfs' %}
    - device: {{node}}:{{salt['pillar.get']('sshfs-mesh:path', '/srv/data')}}/{{node}}
    - fstype: {{salt['pillar.get']('sshfs-mesh:type', 'fuse')}}
{% elif salt['pillar.get']('sshfs-mesh:type', 'fuse') == 'cifs' %}
    - device: //{{node}}{{salt['pillar.get']('sshfs-mesh:path', '/srv/data')}}/{{node}}
    - fstype: {{salt['pillar.get']('sshfs-mesh:type', 'fuse')}}
{% endif %}
    - dump: 0
    - pass_num: 0
    - persist: True
    - mkmnt: True
{% if salt['pillar.get']('sshfs-mesh:opts', []) %}
    - opts:
{%- for opt in salt['pillar.get']('sshfs-mesh:opts', []) %}
      - {{opt}}
{%- endfor %}
{% endif %}
{% endif %}
{% endfor %}
