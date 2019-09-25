#!/bin/bash

if [[ -z $DBUSER ]]; then
  echo "Export DBUSER to environment variable"
  exit
fi

if [[ -z $DBPASSWORD ]]; then
  echo "Export DBPASSWORD to environment variable"
  exit
fi

if [[ -z $DBNAME ]]; then
  echo "Export DBNAME to environment variable"
  exit
fi

if [[ -z $KEY ]]; then
  echo "Export KEY to environment variable"
  exit
fi

if [[ -z $PRIVATE_KEY ]]; then
  echo "Export PRIVATE_KEY to environment variable"
  exit
fi

# set +o history

# linux only
# sudo adduser $DBUSER
# sudo -u postgres createuser --superuser $DBUSER
# sudo -u postgres psql -c "ALTER USER $DBUSER WITH PASSWORD '$DBPASSWORD';"
psql -c "ALTER USER $DBUSER WITH PASSWORD $DBPASSWORD;"

sudo -u $DBUSER dropdb $DBNAME
sudo -u $DBUSER createdb -O $DBUSER $DBNAME
# Creating tables from setup.sql
sudo -u $DBUSER psql "postgresql://$DBUSER:$DBPASSWORD@localhost/$DBNAME" -f ${PWD}/setup.sql


# Gen encryption keys and encrypted password
var=$(ISTESTNET=1 PRIVATE_KEY=$PRIVATE_KEY KEY=$KEY CLIPASSWORD=$CLIPASSWORD node keygen.js)
bnbPubKey=$(echo $var | cut -d, -f1)
bnbAddress=$(echo $var | cut -d, -f2)
bnbEncrSeed=$(echo $var | cut -d, -f3)
bnbEncrKey=$(echo $var | cut -d, -f4)
echo "bnbEncrSeed = $bnbEncrSeed"
echo "bnbEncrClipassword = $bnbEncrClipassword"
echo "bnbEncrKey = $bnbEncrKey"
echo "bnbPubKey = $bnbPubKey"
echo "bnbAddress = $bnbAddress"

# Gen encryption keys and encrypted password
# var=$(ISTESTNET=1 PRIVATE_KEY=$CLIENT_PRIVATE_KEY KEY=$CLIENT_KEY CLIPASSWORD=$CLIENT_CLIPASSWORD node keygen.js)
# clientBnbPubKey=$(echo $var | cut -d, -f1)
# clientBnbAddress=$(echo $var | cut -d, -f2)
# clientBnbEncrSeed=$(echo $var | cut -d, -f3)
# clientBnbEncrKey=$(echo $var | cut -d, -f4)
# echo "clientBnbEncrSeed = $clientBnbEncrSeed"
# echo "clientBnbEncrClipassword = $clientBnbEncrClipassword"
# echo "clientBnbEncrKey = $clientBnbEncrKey"
# echo "clientBnbPubKey = $clientBnbPubKey"
# echo "clientBnbAddress = $clientBnbAddress"

erc20_address=0xD379255277e87E3636708A71F7A845A86f8c591d
eth_account_address=0xBE2E9AAd36a3C3C0c189A9C1f2e4E73bCD472a57
eth_private_key=
echo "erc20_address = $erc20_address"
echo "eth_account_address = $eth_account_address"
echo "eth_private_key = $eth_private_key"

# set -o history

# You should keep your own copy of the following secrets. unset to ensure safety.
# You might also need to clear bash history to avoid leaking secrets.
# unset DBPASSWORD
# unset PRIVATE_KEY

psql --user $DBUSER "postgresql://$DBUSER:$DBPASSWORD@localhost/$DBNAME" -c "
  insert into eth_accounts VALUES (
    'erc_account_uuid',
    '$eth_private_key',
    '$eth_account_address',
   timezone(\'utc\', now()),
    'erc_account_encr_key'
  );
"

psql --user $DBUSER "postgresql://$DBUSER:$DBPASSWORD@localhost/$DBNAME" -c "
  insert into client_accounts_eth VALUES (
    'erc_account_uuid',
    '$eth_account_address',
    'bnb_account_uuid_client',
   timezone(\'utc\', now())
  );
"

psql --user $DBUSER "postgresql://$DBUSER:$DBPASSWORD@localhost/$DBNAME" -c "
  INSERT INTO bnb_accounts VALUES (
    'bnb_account_uuid',
    '$bnbPubKey',
    '$bnbEncrSeed',
    '$bnbAddress',
    'bnbcli-keyname-optional',
    '$bnbEncrKey',
   timezone(\'utc\', now())
  );
"

# psql --user $DBUSER "postgresql://$DBUSER:$DBPASSWORD@localhost/$DBNAME" -c "
#   INSERT INTO client_bnb_accounts VALUES (
#     'bnb_account_uuid_client',
#     '$clientBnbPubKey',
#     '$clientBnbEncrSeed',
#     '$clientBnbAddress',
#     'client-bnbcli-keyname-optional',
#     '$clientBnbEncrKey',
#    timezone(\'utc\', now())
#   );
# "

token_uuid=ONE_uuid

psql --user $DBUSER "postgresql://$DBUSER:$DBPASSWORD@localhost/$DBNAME" -c "
  insert into tokens (
    uuid,
    name,
    symbol,
    unique_symbol,
    total_supply,
    erc20_address,
    eth_account_uuid,
    bnb_account_uuid,
    processed,
    listing_proposed,
    listing_proposal_uuid,
    listed,
    created,
    mintable,
    minimum_swap_amount,
    fee_per_swap,
    process_date,
    bnb_to_eth_enabled,
    eth_to_bnb_enabled
  ) values (
    '$token_uuid', 'Harmony ONE', 'ONE', 'ONE-C00', 10000000000,
    '$erc20_address',
    'erc_account_uuid', 'bnb_account_uuid',
    true, true, 'list_proposal_uuid',
    true, timezone(\'utc\', now()), true, 1000, 0, timezone(\'utc\', now()), true, false
  );
"
