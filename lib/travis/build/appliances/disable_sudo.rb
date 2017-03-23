require 'travis/build/appliances/base'

module Travis
  module Build
    module Appliances
      class DisableSudo < Base
        WRITE_SUDO = <<-EOC
cat <<-'EOF' > _sudo
if [[ -f \$HOME/.sudo-run ]]; then
  exit 0
fi

echo -e "\\\\033[33;1mThis job is running on container-based infrastructure, which does not allow use of 'sudo', setuid and setguid executables.\\\\033[0m
\\\\033[33;1mIf you require sudo, add 'sudo: required' to your .travis.yml\\\\033[0m
"

touch \$HOME/.sudo-run

EOF
        EOC
        DISABLE_SUID = 'sudo -n sh -c "find / \\( -perm -4000 -o -perm -2000 \\) -a ! -name sudo -exec chmod a-s {} \; 2>/dev/null"'
        CLEANUP = 'sudo -n sh -c "chmod 4755 _sudo; chown root:root _sudo; mv _sudo `which sudo`; find / -perm -4000 -a ! -name sudo -exec chmod a-s {} \; 2>/dev/null && sed -e \'s/^%.*//\' -i.bak /etc/sudoers && rm -f /etc/sudoers.d/travis"'

        def apply
          sh.raw WRITE_SUDO
          sh.cmd CLEANUP
        end

        def apply?
          data.disable_sudo?
        end
      end
    end
  end
end
