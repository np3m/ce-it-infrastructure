#!/bin/bash -v

set -e

MYSQL_ROOT_PASSWD=$(cat /run/secrets/mysql_root_passwd)
MYSQL_DOCDBRW_PASSWD=$(cat /run/secrets/mysql_docdbrw_passwd)
MYSQL_DOCDBRO_PASSWD=$(cat /run/secrets/mysql_docdbro_passwd)

if [ ! -f /var/lib/mysql/docdb.init ] ; then
mysql -u root << EOF
USE dcc_docdb;
ALTER TABLE \`SecurityGroup\` MODIFY Name CHAR(64);
DELETE FROM \`SecurityGroup\` WHERE GroupID <> 1 AND GroupID <> 3;
INSERT INTO \`SecurityGroup\` VALUES(2, 'CO:admins', 'Administrators', CURRENT_TIMESTAMP, 1, 1, 1, 1, '1');
INSERT INTO \`SecurityGroup\` VALUES(4, 'NP3MPIs', 'NP3M PIs and CoPIs', CURRENT_TIMESTAMP, 1, 1, 1, 0, '1');
INSERT INTO \`SecurityGroup\` VALUES(5, 'NP3M', 'NP3M Members', CURRENT_TIMESTAMP, 1, 0, 1, 0, '1');
INSERT INTO \`SecurityGroup\` VALUES(6, 'NSF', 'NP3M NSF Program Officers', CURRENT_TIMESTAMP, 1, 0, 1, 0, '1');
INSERT INTO \`SecurityGroup\` VALUES(7, 'NP3MAdvisoryBoard', 'NP3M Advisory Committee', CURRENT_TIMESTAMP, 1, 0, 1, 0, '1');
INSERT INTO \`SecurityGroup\` VALUES(8, 'NP3MSIs', 'NP3M Senior Investigators', CURRENT_TIMESTAMP, 1, 0, 1, 0, '1');
INSERT INTO \`SecurityGroup\` VALUES(9, 'NP3MPostdocs', 'NP3M Postdocs', CURRENT_TIMESTAMP, 1, 0, 1, 0, '1');
INSERT INTO \`SecurityGroup\` VALUES(10, 'NP3MCollaborators', 'NP3M Collaborators', CURRENT_TIMESTAMP, 1, 0, 1, 0, '1');
DELETE FROM \`GroupHierarchy\`;
INSERT INTO \`GroupHierarchy\` VALUES(1, 101, 100, CURRENT_TIMESTAMP);
INSERT INTO \`GroupHierarchy\` VALUES(2, 102, 100, CURRENT_TIMESTAMP);
INSERT INTO \`GroupHierarchy\` VALUES(3, 102, 101, CURRENT_TIMESTAMP);
DELETE FROM \`Institution\`;
INSERT INTO \`Institution\` VALUES(1, 'NSF', 'National Science Foundation', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(2, 'SU', 'Syracuse University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(3, 'IU', 'Indiana University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(4, 'PSU', 'Pennsylvania State University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(5, 'UH', 'University of Houston', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(6, 'UTK', 'University of Tennessee, Knoxville', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(7, 'Kent', 'Kent State University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(8, 'LANL', 'Los Alamos National Laboratory', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(9, 'UNC', 'University of North Carolina, Chapel Hill', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(10, 'UNH', 'University of New Hampshire', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(11, 'TAMU', 'Texas A&M University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(12, 'OSU', 'Oregon State University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(13, 'MSU', 'Michigan State University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(14, 'CSUF', 'California State University, Fullerton', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(15, 'Iowa', 'Iowa State University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(16, 'ND', 'Notre Dame University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(17, 'RIT', 'Rochester Institute of Technology', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(18, 'Cal', 'University of California, Berkeley', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(19, 'UW', 'University of Washington', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(20, 'TUD', 'Technical University Darmstadt', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(21, 'Hann', 'Max Planck Institute For Gravitational Physics Hannover', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(22, 'Soton', 'University of Southhampton', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(23, 'Jena', 'University Jena', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(24, 'Wupp', 'Universitat of Wuppertal', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(25, 'TRIUMF', 'TRIUMF', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(26, 'Surrey', 'University of Surrey', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(27, 'Stonybrook', 'Stony Brook University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(28, 'Lyon', 'Institut de Physique de 2 infinis de Lyon', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(29, 'Ohio', 'Ohio University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(30, 'ORNL', 'Oak Ridge National Laboratory', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(31, 'INFN', 'INFN', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(32, 'Trento', 'University of Trento', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(33, 'FIU', 'Florida International University', CURRENT_TIMESTAMP);
DELETE FROM \`AuthorGroupDefinition\`;
INSERT INTO \`AuthorGroupDefinition\` VALUES(1, 'NP3MPIs', 'NP3M PIs');
INSERT INTO \`AuthorGroupDefinition\` VALUES(2, 'NP3M', 'NP3M');
DELETE FROM \`EventGroup\`;
INSERT INTO \`EventGroup\` VALUES(1, 'PI Meetings', 'PI Meetings', CURRENT_TIMESTAMP);
INSERT INTO \`EventGroup\` VALUES(2, 'NP3M Meetings', 'NP3M Meetings', CURRENT_TIMESTAMP);
INSERT INTO \`EventGroup\` VALUES(3, 'Advisory Board Meetings', 'Advisory Board Meetings', CURRENT_TIMESTAMP);
DELETE FROM \`EventTopic\`;
INSERT INTO \`DocumentType\` VALUES(16, 'N - Funding proposals', 'Proposals to funding agencies (federal or private foundation)', CURRENT_TIME, 1);
UPDATE \`DocumentType\` SET NextDocNumber = 1;
UPDATE \`DocumentType\` SET LongType = 'Serial Numbers for NP3M Equipment' WHERE DocTypeID=9;
DELETE from \`TopicHint\`;
DELETE from \`Topic\`;
INSERT INTO \`Topic\` VALUES(1, 'Mangement', 'Management', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(2, 'Science', 'Science', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(3, 'EPO', 'Education and Outreach', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(4, 'Proposals', 'Proposals', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(5, 'Reports', 'Reports', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(6, 'QCD', 'QCD', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(7, 'Finite Temperatures', 'Finite Temperatures', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(8, 'Nucleosynthesis', 'Nucleosynthesis', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(9, 'Neutrino Opacities', 'Neutrino Opacities', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(10, 'Nuclear Observables', 'Nuclear Observables', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(11, 'Nuclear Heating', 'Nuclear Heating', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(12, 'Chiral EFT', 'Chiral EFT', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(13, 'Simulations', 'Simulations', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(14, 'Disks', 'Disks', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(15, 'Kilonovae', 'Kilonovae', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(16, 'BNS', 'Binary Neutron Stars', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(17, 'NSBH', 'Neutron Star Black Hole Binaries', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(18, 'Inspiral', 'Inspiral', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(19, 'Merger', 'Merger', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(20, 'Remnant', 'Remnant', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(21, 'Tidal Deformabilty', 'Tidal Deformabilty', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(22, 'Parameter Measurement', 'Parameter Measurement', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(23, 'GW Observables', 'GW Observables', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(24, 'EM Observables', 'EM Observables', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(25, 'Summer School', 'Summer School', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(26, 'K-12', 'K-12', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(27, 'Colloquium', 'Colloquium', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(28, 'Seminar', 'Seminar', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(29, 'Working Group', 'Working Group', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(30, 'High-Temperature WG', 'High-Temperature WG', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(31, 'Multi-Messenger WG', 'Multi-Messenger WG', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(32, 'Simulations WG', 'Simulations WG', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(33, 'FRIB-GW WG', 'FRIB-GW WG', CURRENT_TIMESTAMP);
DELETE FROM \`TopicHierarchy\`;
INSERT INTO \`TopicHierarchy\` VALUES (1, 4, 1, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (2, 5, 1, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (3, 6, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (4, 7, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (5, 8, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (6, 9, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (7, 10, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (8, 11, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (9, 12, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (10, 13, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (11, 14, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (12, 15, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (13, 16, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (14, 17, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (15, 18, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (16, 19, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (17, 20, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (18, 21, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (19, 22, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (20, 23, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (21, 24, 2, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (22, 25, 3, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (23, 26, 3, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (24, 27, 3, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (25, 28, 3, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (26, 30, 29, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (27, 31, 29, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (28, 32, 29, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (29, 33, 29, CURRENT_TIMESTAMP);
EOF
mysql -u root << EOF
GRANT USAGE ON *.* TO 'docdbrw'@'%';
GRANT USAGE ON *.* TO 'docdbro'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON dcc_docdb.* TO 'docdbrw'@'%';
GRANT SELECT ON dcc_docdb.* TO 'docdbro'@'%';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWD}');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('${MYSQL_ROOT_PASSWD}');
SET PASSWORD FOR 'docdbrw'@'localhost' = PASSWORD('${MYSQL_DOCDBRW_PASSWD}');
SET PASSWORD FOR 'docdbro'@'localhost' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
SET PASSWORD FOR 'docdbrw'@'%' = PASSWORD('${MYSQL_DOCDBRW_PASSWD}');
SET PASSWORD FOR 'docdbro'@'%' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
SET PASSWORD FOR 'wikiuser'@'localhost' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
SET PASSWORD FOR 'wikidb_restore'@'localhost' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
FLUSH PRIVILEGES;
EOF
touch /var/lib/mysql/docdb.init
fi

sed -i -e "/db_rwpass/ s/Change.Me.too\!/${MYSQL_DOCDBRW_PASSWD}/;" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm
sed -i -e "/db_ropass/ s/Change.Me.too\!/${MYSQL_DOCDBRO_PASSWD}/;" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm
sed -i -e "/db_ropass/ s/Change.Me.too\!/${MYSQL_DOCDBRO_PASSWD}/;" /usr1/www/cgi-bin/DocDB/SiteConfig.pm

exit 0
