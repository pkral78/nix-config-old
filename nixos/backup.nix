{ config, pkgs, lib, ... }:

{
    
#     services.borgbackup.jobs =
#     let common-excludes = [          
#           ".cache"        
#           "*/Cache"          
#           ".config/Slack/logs"
#           ".config/Code Cached"
#           ".container-diff"
#           ".npm/_cacache"
#           # Work related dirs
#           "*/node_modules"
#           "*/build"
#           "*/.tox"
#           "*/venv"
#           "*/.venv*"
#         ];
#         work-dirs = [
#           "/home/danbst/dev/company1"
#           "/home/danbst/dev/company2"
#         ];
#         basicBorgJob = name: {
#           encryption.mode = "none";
#           environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i /home/danbst/.ssh/id_ed25519";
#           environment.BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "1";
#           extraCreateArgs = "--verbose --stats --checkpoint-interval 600";
#           repo = "ssh://user@example.com//media/backup/${name}";
#           compression = "zstd,1";
#           startAt = "daily";
#           user = "danbst";
#         };
#   in {
#     home-pkral = basicBorgJob "backups/station/home-pkral" // rec {
#       paths = "/home/pkral";
#       exclude = work-dirs ++ map (x: paths + "/" + x) (common-excludes ++ [
#         "Downloads"
#       ]);
#     };
#     home-danbst-downloads = basicBorgJob "backups/station/home-danbst-downloads" // rec {
#       paths = "/home/danbst/Downloads";
#       exclude = map (x: paths + "/" + x) common-excludes;
#     };
#     extra-drive-important = basicBorgJob "backups/station/extra-drive-important" // rec {
#       paths = "/media/extra-drive/important";
#       exclude = map (x: paths + "/" + x) common-excludes;
#     };
#   };
  
}