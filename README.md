# Dacade-SuiMove-TicketingSystem

## 1 Entity Definition

- ADMIN
- OrganizationList
- ServiceOrganizationCap
- ServiceOrganization
- Service
- PackageServices
- ServiceCertification
- PackageServicesCertification

## 2 Entity Relationship

- Package publisher(`ADMIN`) will charge 1% commission.
- Use One-Time-Witness(`ADMIN`) to create `Publisher`, use this as a voucher when the publisher withdraws money.
- `OrganizationList` is a shared object, which used to store infomation about all the `ServiceOrganization`.
- `ServiceOrganizationCap` is owned by manager of it's corresponding `ServiceOrganization`, only with this permission, the manager can modify the content.
- `ServiceOrganization` is used to store this organizations's details, `Service` and `PackageServices` are the import part of it.
- `Service` stores a single service.
- `PackageServices` storage service package.
- `ServiceCertification` is the customer's certificate for purchasing a single service.
- `PackageServicesCertification` is the certificate for customers to purchase service package.

## 3 Economic Design

- Any user can create it's own service organization, provide individual services or service package, and set the price according to the actual situation.
- Customers obtain service vouchers by paying the corresponding amount, and use the vouchers to enjoy subsequent services.
- Only when the customer actually enjoys the service will the corresponding payment reach the merchant's account.
- If the customer purchases but has not yet enjoyed the service and the organization cancels the business, the amount will be refunded in full.
- If the customer chooses to refund due to their own reasons, they need to pay a 10% handling fee and the remaining amount will be refunded to the customer's wallet.
- When the balance is not less than 100, the merchant can choose to withdraw cash. This process will pay 1% to the platform provider.

## 4 API Definition

- **publisher_withdraw:** Publisher withdraws earnings.
- **organization_withdraw:** Service organization's manager withdraws earnings.
- **create_service_organization:** Create a new service organization.
- **destroy_service_organization:** Deregister service organization.
- **create_service:** Create a new single service.
- **destroy_service:** Cancle a single service.
- **modify_package_services:** Change the services included in the package.
- **modify_package_services_price:** Change the package's price.
- **modify_package_service_and_price:** Change the services included in the package and it's price.
- **create_package_services:** Create a new service package with default price(85% of the total service fees).
- **create_package_services_and_price:** Create a new service package with specified price.
- **destroy_package_services:** Cancle a service package.
- **query_organization_list:** Check out the list of service organizations.
- **query_organization_services:** Check out the services a certain service organization can provide.
- **buy_service:** Purchase individual services.
- **refund_service:** Refunds for individual services.
- **enjoy_service:** Enjoy individual services.
- **buy_package_services:** Purchase a service package.
- **refund_package_services:** Refunds for service package.
- **enjoy_package_services:** Enjoy a service package.
- **update_package_services:** Update the items included in the package on the voucher and refund the canceled services.

## 5 Testing

**Note:** The testing process is deployed on the test network. Due to the variety of functions, only some of them are selected.

### 5.1 publish

- **run command**

`sui client publish --gas-budget 100000000`

- **important output**

```bash
╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                            │
│  ┌──                                                                                                        │
│  │ ObjectID: 0x1f4044ef7050a8305fcf33ce7aed3b91d34a9333ae7efc2af7205b3c286d5f30                             │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                               │
│  │ Owner: Shared                                                                                            │
│  │ ObjectType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::admin::OrganizationList  │
│  │ Version: 28131907                                                                                        │
│  │ Digest: ACTMHcXEBhVKkSPyWHG2utssZc2VtPenPx11iSkXQ1PP                                                     │
│  └──                                                                                                        │
│  ┌──                                                                                                        │
│  │ ObjectID: 0xa4eea40898c7a07fb6c19ff8f91eb7d1cd7972239ccf09dd980d3918710139d6                             │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                               │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )            │
│  │ ObjectType: 0x2::package::UpgradeCap                                                                     │
│  │ Version: 28131907                                                                                        │
│  │ Digest: DfWZyiGJASyHRictNPZaXxBuscP95cBMzj8aU2HR9znb                                                     │
│  └──                                                                                                        │
│  ┌──                                                                                                        │
│  │ ObjectID: 0xcede98cf7512b7bb36d605eaa6b2b40c4d1fe0b5d95508a4a4bb1c9b6ea1e6ed                             │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                               │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )            │
│  │ ObjectType: 0x2::package::Publisher                                                                      │
│  │ Version: 28131907                                                                                        │
│  │ Digest: 7ZTY3uhTAy66zuuQhzGuTuhd85WMbQbLgYCHER3enV7W                                                     │
│  └──                                                                                                        │
│ Mutated Objects:                                                                                            │
│  ┌──                                                                                                        │
│  │ ObjectID: 0x01676de212960b0689245914312ac6be3b4d5cffa0cae91ef527441b894f746a                             │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                               │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )            │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                               │
│  │ Version: 28131907                                                                                        │
│  │ Digest: EyVfUXRunZ1tUZJu9xPMPMfjVXECQdjDqrNaihwLKCVo                                                     │
│  └──                                                                                                        │
│ Published Objects:                                                                                          │
│  ┌──                                                                                                        │
│  │ PackageID: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41                            │
│  │ Version: 1                                                                                               │
│  │ Digest: 3pGSsGYWDBVZBvDzRMb9pgCqzQYixdFxPJPcDGUKTrzn                                                     │
│  │ Modules: admin, customer                                                                                 │
│  └──                                                                                                        │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **record ID**

```bash
export PACKAGE=0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41
export PUBLISHER=0xcede98cf7512b7bb36d605eaa6b2b40c4d1fe0b5d95508a4a4bb1c9b6ea1e6ed
export ORGANIZATIONLIST=0x1f4044ef7050a8305fcf33ce7aed3b91d34a9333ae7efc2af7205b3c286d5f30
```

### 5.2 create_service_organization

- **run command**

`sui client call --package $PACKAGE --module admin --function create_service_organization --args $ORGANIZATIONLIST organization_test1 --gas-budget 100000000`

- **important output**

```bash
╭────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                                                             │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                                                           │
│  ┌──                                                                                                                                                       │
│  │ ObjectID: 0x787784d9199ba7b4cc737968f757e51618161a20011a3587d47fc6a41a3d8d2f                                                                            │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                                                                              │
│  │ Owner: Object ID: ( 0xfd82ff66cfa34dd54a73800f6b84353687c196cddbb018e7e405262b8d198518 )                                                                │
│  │ ObjectType: 0x2::dynamic_field::Field<0x2::object::ID, 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::admin::ServiceOrganization>  │
│  │ Version: 28131908                                                                                                                                       │
│  │ Digest: mPs2f9vzsR4h6avMUmPuxmZjNvfqexXGiRjp5syAPmb                                                                                                     │
│  └──                                                                                                                                                       │
│  ┌──                                                                                                                                                       │
│  │ ObjectID: 0xea3dcaae81667ff00e5a7ac31326f1e5d5a8e5758ce4ef88f7230a4537bf2485                                                                            │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                                                                              │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )                                                           │
│  │ ObjectType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::admin::ServiceOrganizationCap                                           │
│  │ Version: 28131908                                                                                                                                       │
│  │ Digest: PLRK1ZpfJ1SGcudcDcBdqDdTFBoPHLj2SAU3rgk8PZM                                                                                                     │
│  └──                                                                                                                                                       │
│ Mutated Objects:                                                                                                                                           │
│  ┌──                                                                                                                                                       │
│  │ ObjectID: 0x01676de212960b0689245914312ac6be3b4d5cffa0cae91ef527441b894f746a                                                                            │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                                                                              │
│  │ Owner: Account Address ( 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67 )                                                           │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                                              │
│  │ Version: 28131908                                                                                                                                       │
│  │ Digest: 5guVeUMee7L7qzXx919o1eKiBQK5hCcyyAnHJvBcfNdQ                                                                                                    │
│  └──                                                                                                                                                       │
│  ┌──                                                                                                                                                       │
│  │ ObjectID: 0x1f4044ef7050a8305fcf33ce7aed3b91d34a9333ae7efc2af7205b3c286d5f30                                                                            │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                                                                              │
│  │ Owner: Shared                                                                                                                                           │
│  │ ObjectType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::admin::OrganizationList                                                 │
│  │ Version: 28131908                                                                                                                                       │
│  │ Digest: B2ghJsWe8mez3cfMTuwoqJFV2p5rFxB4DZcXixxZKDR7                                                                                                    │
│  └──                                                                                                                                                       │
╰────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **record ID**

`export SERVICEORGANIZATIONCAP=0xea3dcaae81667ff00e5a7ac31326f1e5d5a8e5758ce4ef88f7230a4537bf2485`

### 5.3 create_service

- **run command**

```bash
sui client call --package $PACKAGE --module admin --function create_service --args $SERVICEORGANIZATIONCAP $ORGANIZATIONLIST service_test_1 50 --gas-budget 100000000
sui client call --package $PACKAGE --module admin --function create_service --args $SERVICEORGANIZATIONCAP $ORGANIZATIONLIST service_test_2 50 --gas-budget 100000000
```

### 5.4 switch address and query services

- **switch address**

`sui client switch --address peaceful-hiddenite`

- **query_organization_list**

```bash
sui client call --package $PACKAGE --module customer --function query_organization_list --args $ORGANIZATIONLIST --gas-budget 100000000

# important output
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                          │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                              │
│  │ EventID: 9ewfm1HnvaaC2R4nnK7Zctcbb42XUMgzNLPRDFQm7BNj:0                                                        │
│  │ PackageID: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41                                  │
│  │ Transaction Module: customer                                                                                   │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                     │
│  │ EventType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::customer::OrganizationListEvent │
│  │ ParsedJSON:                                                                                                    │
│  │   ┌───────────────────┬────────────────────────────────────────────────────────────────────┐                   │
│  │   │ organization_id   │ 0xea3dcaae81667ff00e5a7ac31326f1e5d5a8e5758ce4ef88f7230a4537bf2485 │                   │
│  │   ├───────────────────┼────────────────────────────────────────────────────────────────────┤                   │
│  │   │ organization_name │ organization_test1                                                 │                   │
│  │   └───────────────────┴────────────────────────────────────────────────────────────────────┘                   │
│  └──                                                                                                              │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

# record ID
export ORGANIZATIONID=0xea3dcaae81667ff00e5a7ac31326f1e5d5a8e5758ce4ef88f7230a4537bf2485
```

- **query_organization_services**

```bash
sui client call --package $PACKAGE --module customer --function query_organization_services --args $ORGANIZATIONID $ORGANIZATIONLIST --gas-budget 100000000

# important output
╭──────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                 │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                     │
│  │ EventID: 97DF15Z7CKpc68AWv5jWLcUvTSAqkeTczHiMdseYgksA:0                                               │
│  │ PackageID: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41                         │
│  │ Transaction Module: customer                                                                          │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                            │
│  │ EventType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::customer::ServiceEvent │
│  │ ParsedJSON:                                                                                           │
│  │   ┌──────────────┬────────────────────────────────────────────────────────────────────┐               │
│  │   │ service_id   │ 0xb4a15bb46d38f61fc89bd942e8816caab6c48cc688dd4b2e023262eebd1c8951 │               │
│  │   ├──────────────┼────────────────────────────────────────────────────────────────────┤               │
│  │   │ service_name │ service_test_1                                                     │               │
│  │   └──────────────┴────────────────────────────────────────────────────────────────────┘               │
│  └──                                                                                                     │
│  ┌──                                                                                                     │
│  │ EventID: 97DF15Z7CKpc68AWv5jWLcUvTSAqkeTczHiMdseYgksA:1                                               │
│  │ PackageID: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41                         │
│  │ Transaction Module: customer                                                                          │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                            │
│  │ EventType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::customer::ServiceEvent │
│  │ ParsedJSON:                                                                                           │
│  │   ┌──────────────┬────────────────────────────────────────────────────────────────────┐               │
│  │   │ service_id   │ 0x6bd5e56f2ef6f5d2ff27ea55526e725fb1a50e0ecf29e839c05b4e7b2853ac43 │               │
│  │   ├──────────────┼────────────────────────────────────────────────────────────────────┤               │
│  │   │ service_name │ service_test_2                                                     │               │
│  │   └──────────────┴────────────────────────────────────────────────────────────────────┘               │
│  └──                                                                                                     │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯

# record ID
export SERVICE1ID=0xb4a15bb46d38f61fc89bd942e8816caab6c48cc688dd4b2e023262eebd1c8951
export SERVICE2ID=0x6bd5e56f2ef6f5d2ff27ea55526e725fb1a50e0ecf29e839c05b4e7b2853ac43
```

**Note:** Subsequent instances will omit the address switching operation, and all content not managed by the service organization will be performed under ordinary users.

### 5.5 create_package_services

- **run command**

`sui client call --package $PACKAGE --module admin --function create_package_services --args $SERVICEORGANIZATIONCAP $ORGANIZATIONLIST "[$SERVICE1ID, $SERVICE2ID]" --gas-budget 100000000`

### 5.6 query_organization_services

- **run and export**

```bash
sui client call --package $PACKAGE --module customer --function query_organization_services --args $ORGANIZATIONID $ORGANIZATIONLIST --gas-budget 100000000

# important output
╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                         │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                             │
│  │ EventID: 5Fe2WvfW7f8LEjvHgExYu4qPRosjN7ci7oFRPwFvqpAe:0                                                       │
│  │ PackageID: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41                                 │
│  │ Transaction Module: customer                                                                                  │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                                    │
│  │ EventType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::customer::ServiceEvent         │
│  │ ParsedJSON:                                                                                                   │
│  │   ┌──────────────┬────────────────────────────────────────────────────────────────────┐                       │
│  │   │ service_id   │ 0xb4a15bb46d38f61fc89bd942e8816caab6c48cc688dd4b2e023262eebd1c8951 │                       │
│  │   ├──────────────┼────────────────────────────────────────────────────────────────────┤                       │
│  │   │ service_name │ service_test_1                                                     │                       │
│  │   └──────────────┴────────────────────────────────────────────────────────────────────┘                       │
│  └──                                                                                                             │
│  ┌──                                                                                                             │
│  │ EventID: 5Fe2WvfW7f8LEjvHgExYu4qPRosjN7ci7oFRPwFvqpAe:1                                                       │
│  │ PackageID: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41                                 │
│  │ Transaction Module: customer                                                                                  │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                                    │
│  │ EventType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::customer::ServiceEvent         │
│  │ ParsedJSON:                                                                                                   │
│  │   ┌──────────────┬────────────────────────────────────────────────────────────────────┐                       │
│  │   │ service_id   │ 0x6bd5e56f2ef6f5d2ff27ea55526e725fb1a50e0ecf29e839c05b4e7b2853ac43 │                       │
│  │   ├──────────────┼────────────────────────────────────────────────────────────────────┤                       │
│  │   │ service_name │ service_test_2                                                     │                       │
│  │   └──────────────┴────────────────────────────────────────────────────────────────────┘                       │
│  └──                                                                                                             │
│  ┌──                                                                                                             │
│  │ EventID: 5Fe2WvfW7f8LEjvHgExYu4qPRosjN7ci7oFRPwFvqpAe:2                                                       │
│  │ PackageID: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41                                 │
│  │ Transaction Module: customer                                                                                  │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                                    │
│  │ EventType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::customer::PackageServicesEvent │
│  │ ParsedJSON:                                                                                                   │
│  │   ┌─────────────────────┬────────────────────────────────────────────────────────────────────┐                │
│  │   │ package_services_id │ 0xd1f30ffcf54817a02da70251d4fd85949ecad34e772b0c4aee43304c705bc1c0 │                │
│  │   ├─────────────────────┼────────────────────────────────────────────────────────────────────┤                │
│  │   │ services            │ service_test_1                                                     │                │
│  │   │                     ├────────────────────────────────────────────────────────────────────┤                │
│  │   │                     │ service_test_2                                                     │                │
│  │   └─────────────────────┴────────────────────────────────────────────────────────────────────┘                │
│  └──                                                                                                             │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

# record ID
export PACKAGESERVICEID=0xd1f30ffcf54817a02da70251d4fd85949ecad34e772b0c4aee43304c705bc1c0
```

### 5.7 buy_package_services

- **run command**

```bash
sui client gas

# output
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x516586df0c5e9c9567696840981f720d64335ac6e8ad409f4ba4843b8dc2274a │ 100                │ 0.00             │
│ 0x82ec01655d746b42dba5c5951841472e5d1715e74238a5ef8e39d0b0566dc3be │ 982798853          │ 0.98             │
│ 0x8ef6503cb330c4114bc7995a403adf4015190d8effc02504fd849377caa6499b │ 963358100          │ 0.96             │
│ 0xad3fa2545f5db01bd4d349871df5af4d6de913600e7e3e032d5229c006d35851 │ 100                │ 0.00             │
│ 0xcb24b30fe196f4f2ca6d5f8d87a273bf168f7f86f6b7ae3f1f20fc5cf447e557 │ 940920294          │ 0.94             │
│ 0xe4f2d7831241583d534271d8d777d7558290124779e98e03b059a2fe108d37b0 │ 989                │ 0.00             │
╰────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────╯

export COIN=0x82ec01655d746b42dba5c5951841472e5d1715e74238a5ef8e39d0b0566dc3be

sui client call --package $PACKAGE --module customer --function buy_package_services --args $ORGANIZATIONLIST $ORGANIZATIONID $PACKAGESERVICEID $COIN --gas-budget 100000000
```

- **important output**

```bash
╭────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                             │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                           │
│  ┌──                                                                                                                       │
│  │ ObjectID: 0x4e7eebf65218cf0ed484fdba0182434cdd24ff3140af950c228442447790b42c                                            │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                              │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                           │
│  │ ObjectType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::customer::PackageServicesCertification  │
│  │ Version: 28131913                                                                                                       │
│  │ Digest: 7fUc3pVppMEcQPQ1QRVwcp6Y9rWp5jKw2qfB76E1vze9                                                                    │
│  └──                                                                                                                       │
│ Mutated Objects:                                                                                                           │
│  ┌──                                                                                                                       │
│  │ ObjectID: 0x82ec01655d746b42dba5c5951841472e5d1715e74238a5ef8e39d0b0566dc3be                                            │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                              │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                           │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                              │
│  │ Version: 28131913                                                                                                       │
│  │ Digest: shAMmcj8Ca6SPC7TomPqxQviSdN4UQfwcZmKSJ2nNZ8                                                                     │
│  └──                                                                                                                       │
│  ┌──                                                                                                                       │
│  │ ObjectID: 0x8ef6503cb330c4114bc7995a403adf4015190d8effc02504fd849377caa6499b                                            │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                              │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                           │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                              │
│  │ Version: 28131913                                                                                                       │
│  │ Digest: ANDLCwxmDXNcurMemzk2fp22SWQfDdVVJkyYHQKhJj2k                                                                    │
│  └──                                                                                                                       │
╰────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **record ID**

`export PACKAGESERVICESCERTIFICATION=0x4e7eebf65218cf0ed484fdba0182434cdd24ff3140af950c228442447790b42c`

### 5.8 destroy_service and query

- **destroy**

`sui client call --package $PACKAGE --module admin --function destroy_service --args $SERVICEORGANIZATIONCAP $ORGANIZATIONLIST $SERVICE1ID --gas-budget 100000000`

- **query**

```bash
sui client call --package $PACKAGE --module customer --function query_organization_services --args $ORGANIZATIONID $ORGANIZATIONLIST --gas-budget 100000000

# important output
╭──────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                 │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                     │
│  │ EventID: A8d3a5CHgpjpmK8HyLH1e4xs3ww15ary8JSw6ts8BUBL:0                                               │
│  │ PackageID: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41                         │
│  │ Transaction Module: customer                                                                          │
│  │ Sender: 0x9e4092b6a894e6b168aa1c6c009f5c1c1fcb83fb95e5aa39144e1d2be4ee0d67                            │
│  │ EventType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::customer::ServiceEvent │
│  │ ParsedJSON:                                                                                           │
│  │   ┌──────────────┬────────────────────────────────────────────────────────────────────┐               │
│  │   │ service_id   │ 0x6bd5e56f2ef6f5d2ff27ea55526e725fb1a50e0ecf29e839c05b4e7b2853ac43 │               │
│  │   ├──────────────┼────────────────────────────────────────────────────────────────────┤               │
│  │   │ service_name │ service_test_2                                                     │               │
│  │   └──────────────┴────────────────────────────────────────────────────────────────────┘               │
│  └──                                                                                                     │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### 5.9 update_package_services

- **run commang**

```bash
sui client call --package $PACKAGE --module customer --function update_package_services --args $PACKAGESERVICESCERTIFICATION $ORGANIZATIONLIST --gas-budget 100000000

# important output
╭─────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                    │
│  │ EventID: FT639fjhsoFqeoU79XH21tJYmKKiKTwMb97A3KtWNGzG:0                                              │
│  │ PackageID: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41                        │
│  │ Transaction Module: customer                                                                         │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                           │
│  │ EventType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::customer::RefundEvent │
│  │ ParsedJSON:                                                                                          │
│  │   ┌───────┬────────────────────────────────────────────────────────┐                                 │
│  │   │ note  │ service organization or package services has canceled! │                                 │
│  │   ├───────┼────────────────────────────────────────────────────────┤                                 │
│  │   │ value │ 85                                                     │                                 │
│  │   └───────┴────────────────────────────────────────────────────────┘                                 │
│  └──                                                                                                    │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **query gas**

```bash
sui client gas

# output
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x516586df0c5e9c9567696840981f720d64335ac6e8ad409f4ba4843b8dc2274a │ 100                │ 0.00             │
│ 0x82ec01655d746b42dba5c5951841472e5d1715e74238a5ef8e39d0b0566dc3be │ 983283808          │ 0.98             │
│ 0x8ef6503cb330c4114bc7995a403adf4015190d8effc02504fd849377caa6499b │ 959830340          │ 0.95             │
│ 0x9bfd02b5901fcdcce225336c009d881b191fad46b82158dc15b84e1346973523 │ 85                 │ 0.00             │
│ 0xad3fa2545f5db01bd4d349871df5af4d6de913600e7e3e032d5229c006d35851 │ 100                │ 0.00             │
│ 0xcb24b30fe196f4f2ca6d5f8d87a273bf168f7f86f6b7ae3f1f20fc5cf447e557 │ 940920294          │ 0.94             │
│ 0xe4f2d7831241583d534271d8d777d7558290124779e98e03b059a2fe108d37b0 │ 989                │ 0.00             │
╰────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────╯
```

### 5.10 buy service and enjoy

- **buy**

```bash
sui client call --package $PACKAGE --module customer --function buy_service --args $ORGANIZATIONLIST $ORGANIZATIONID $SERVICE2ID $COIN --gas-budget 100000000

# important output
╭────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                     │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                   │
│  ┌──                                                                                                               │
│  │ ObjectID: 0x65599566e55f6bef29d7e67c8d04d10b2c7701459e368fa6ef2288d3e7a0ce66                                    │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                      │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                   │
│  │ ObjectType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::customer::ServiceCertification  │
│  │ Version: 28131915                                                                                               │
│  │ Digest: CCaaGnshMomZHcpegnb4GB2k5TuYSogKxZ4ZdQGAp3h8                                                            │
│  └──                                                                                                               │
│ Mutated Objects:                                                                                                   │
│  ┌──                                                                                                               │
│  │ ObjectID: 0x82ec01655d746b42dba5c5951841472e5d1715e74238a5ef8e39d0b0566dc3be                                    │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                      │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                   │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                      │
│  │ Version: 28131915                                                                                               │
│  │ Digest: 4kHSso6yaPMmZ8VHFKvcbNJjdFLAtvCkJALStidq56ik                                                            │
│  └──                                                                                                               │
│  ┌──                                                                                                               │
│  │ ObjectID: 0x8ef6503cb330c4114bc7995a403adf4015190d8effc02504fd849377caa6499b                                    │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                                      │
│  │ Owner: Account Address ( 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b )                   │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                      │
│  │ Version: 28131915                                                                                               │
│  │ Digest: 4vsaUViSYCkazVVrQHQqbXNT3VPFhb13cDpJTw5gE5mc                                                            │
│  └──                                                                                                               │
╰────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

# record ID
export SERVICECERTIFICATION=0x65599566e55f6bef29d7e67c8d04d10b2c7701459e368fa6ef2288d3e7a0ce66
```

- **enjoy**

```bash
sui client call --package $PACKAGE --module customer --function enjoy_service --args $SERVICECERTIFICATION $ORGANIZATIONLIST --gas-budget 100000000

# important output
╭──────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                 │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                     │
│  │ EventID: 61Rj3VYz3jC5KhPbe2jexoBfJd8Be7fGk6AMG9iffP5z:0                                               │
│  │ PackageID: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41                         │
│  │ Transaction Module: customer                                                                          │
│  │ Sender: 0xf6029b82e355f627b0e3d8941d63e139c4b73b495a2017ef48aaf17cc377457b                            │
│  │ EventType: 0x216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41::customer::EnjoyEvent   │
│  │ ParsedJSON:                                                                                           │
│  │   ┌──────┬──────────────────────────────────────────────────────────────────────────────────────────┐ │
│  │   │ note │ good morning, and in case i don't see you, good afternoon, good evening, and good night! │ │
│  │   └──────┴──────────────────────────────────────────────────────────────────────────────────────────┘ │
│  └──                                                                                                     │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### 5.11 withdraw

- **organization_withdraw**

```bash
sui client call --package $PACKAGE --module admin --function organization_withdraw --args $SERVICEORGANIZATIONCAP $ORGANIZATIONLIST --gas-budget 100000000

# error
Error executing transaction: Failure {
    error: "MoveAbort(MoveLocation { module: ModuleId { address: 216202fdaae06b761222286300e18eb6ef24c2fe5cf7336b7f2da9ab97beea41, name: Identifier(\"admin\") }, function: 2, instruction: 14, function_name: Some(\"organization_withdraw_\") }, 1) in command 0",
}
```

Because our income is less than 100 and cannot be withdrawn, we switch users again, purchase and enjoy the service once.<br>After that, we tried to cash out again.<br>Now, our profit is 100, after the withdrawal, the institution deserves 99, and the platform provider deserves 1.

- **organization_withdraw**

```bash
sui client call --package $PACKAGE --module admin --function organization_withdraw --args $SERVICEORGANIZATIONCAP $ORGANIZATIONLIST --gas-budget 100000000

# query gas
sui client gas
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x01676de212960b0689245914312ac6be3b4d5cffa0cae91ef527441b894f746a │ 601182904          │ 0.60             │
│ 0x03335f68ff3616af7e000b113c56a5ad53e8e8209784ca0a5623f70997c8d948 │ 3182792690         │ 3.18             │
│ 0xd61fa7c67f44180f8987e9de59cae81e2b26215c6209e0a40bc782402344474d │ 99                 │ 0.00             │
│ 0xf0d1ea4828fe7391b41b2b07cc8c4c5fd1831aee6b6a4e5195b236dea20fbde4 │ 666                │ 0.00             │
╰────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────╯
```

- **publisher_withdraw**

```bash
sui client call --package $PACKAGE --module admin --function publisher_withdraw --args $PUBLISHER $ORGANIZATIONLIST --gas-budget 100000000

# query gas
sui client gas
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x01676de212960b0689245914312ac6be3b4d5cffa0cae91ef527441b894f746a │ 599146796          │ 0.59             │
│ 0x03335f68ff3616af7e000b113c56a5ad53e8e8209784ca0a5623f70997c8d948 │ 3182792690         │ 3.18             │
│ 0x8eb492cda5672e5b87541b744962f927b40b3e67119dc5ba437ee8dfb4785595 │ 1                  │ 0.00             │
│ 0xd61fa7c67f44180f8987e9de59cae81e2b26215c6209e0a40bc782402344474d │ 99                 │ 0.00             │
│ 0xf0d1ea4828fe7391b41b2b07cc8c4c5fd1831aee6b6a4e5195b236dea20fbde4 │ 666                │ 0.00             │
╰────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────╯
```

## 6 Disclaimer

This project is for learning purposes only.<br>The code logic and testing are still imperfect and unsafe.<br>If you want to use it for commercial purposes, please bear the possible consequences.

