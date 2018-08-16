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
{% endif %}

{% if salt['pillar.get']('meshmount:type', 'fuse') == 'nfs' %}
meshmount_packages:
  pkg.installed:
    - name: {{ meshmount.pkg_nfs }}
    - pkgs:
      - {{ meshmount.pkg_nfs }}
    - refresh: True
{% endif %}

{% for node in salt['pillar.get']('meshmount:nodes', []) %}
{% if node != grains['id'] %}
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
{% endif %}
{% endfor %}
