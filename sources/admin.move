module ticketing_system::admin {
    use sui::sui::SUI;
    use sui::coin;
    use sui::balance::{Self, Balance};
    use sui::package::{Self, Publisher};
    use std::string::String;
    use sui::table::{Self, Table};

    // ====== error code ======

    const ENotIncome: u64 = 0;
    const ENotEnoughIncome: u64 = 1;
    const ENotCorrectService: u64 = 2;
    const ENotCorrectPackage: u64 = 3;
    const ENotAllCorrectService: u64 = 4;

    // ====== struct ======

    public struct ADMIN has drop {}

    public struct OrganizationList has key {
        id: UID,
        organizations: Table<ID, ServiceOrganization>,
        organizations_ids: vector<ID>,
        publisher_income: Balance<SUI>,
    }

    public struct ServiceOrganizationCap has key {
        id: UID,
    }

    public struct ServiceOrganization has store {
        organization_name: String,
        services: Table<ID, Service>,
        services_ids: vector<ID>,
        package_services: Table<ID, PackageServices>,
        package_services_ids: vector<ID>,
        income: Balance<SUI>,
    }

    public struct Service has store, drop {
        service_name: String,
        price: u64,
    }

    public struct PackageServices has store {
        services: vector<ID>,
        price: u64,
    }

    // ====== function ======

    fun init(otw: ADMIN, ctx: &mut TxContext) {
        // create and transfer Publisher
        package::claim_and_keep(otw, ctx);

        // create and share OrganizationList
        transfer::share_object(OrganizationList {
            id: object::new(ctx),
            organizations: table::new<ID, ServiceOrganization>(ctx),
            organizations_ids: vector<ID>[],
            publisher_income: balance::zero(),
        });
    }

    entry fun publisher_withdraw(_: &Publisher, organization_list: &mut OrganizationList, ctx: &mut TxContext) {
        // check balance
        assert!(organization_list.publisher_income.value() > 0, ENotIncome);

        // get all balance
        let all_balance = organization_list.publisher_income.withdraw_all();
        // transfer the coin to the publisher
        transfer::public_transfer(coin::from_balance(all_balance, ctx), ctx.sender());
    }

    // in order to make the withdrawal function more versatile
    #[allow(lint(self_transfer))]
    fun organization_withdraw_(service_organization: &mut ServiceOrganization, publisher_income: &mut Balance<SUI>, ctx: &mut TxContext) {
        // check balance
        assert!(service_organization.income.value() >= 100, ENotEnoughIncome);

        // get all amount
        let amount = service_organization.income.value();
        // split 1%
        let publisher_earned = service_organization.income.split(amount / 100);
        // join to the publisher_balance
        publisher_income.join(publisher_earned);

        // get the remaining balance
        let all_balance = service_organization.income.withdraw_all();
        // transfer the coin to the organization owner
        transfer::public_transfer(coin::from_balance(all_balance, ctx), ctx.sender());
    }

    entry fun organization_withdraw(service_organization_cap: &ServiceOrganizationCap, organization_list: &mut OrganizationList, ctx: &mut TxContext) {
        // the fact that `service_organization_cap` exists means that `organization_list` must own what it corresponds to
        // so we don’t need to judge here

        // get id
        let organization_id = object::id(service_organization_cap);
        // get and return service organization
        let service_organization = &mut organization_list.organizations[organization_id];

        // withdraw
        organization_withdraw_(service_organization, &mut organization_list.publisher_income, ctx);
    }

    entry fun create_service_organization(organization_list: &mut OrganizationList, organization_name: String, ctx: &mut TxContext) {
        // create service organization cap
        let service_organization_cap = ServiceOrganizationCap {id: object::new(ctx)};

        // create service organization
        let service_organization = ServiceOrganization {
            organization_name,
            services: table::new<ID, Service>(ctx),
            services_ids: vector<ID>[],
            package_services: table::new<ID, PackageServices>(ctx),
            package_services_ids: vector<ID>[],
            income: balance::zero(),
        };

        // get service_organization_cap id as service_organization id
        let service_organization_id = object::id(&service_organization_cap);
        // store service_organization to organization_list
        organization_list.organizations.add(service_organization_id, service_organization);
        organization_list.organizations_ids.push_back(service_organization_id);

        // transfer service_organization_cap to the organization owner
        transfer::transfer(service_organization_cap, ctx.sender());
    }

    entry fun destroy_service(
        service_organization_cap: &ServiceOrganizationCap,
        organization_list: &mut OrganizationList,
        service_id: ID,
    ) {
        let service_organization = get_service_organization(service_organization_cap, organization_list);

        // Check if the service ID is valid
        assert!(
            service_organization.services_ids.contains(&service_id),
            ENotCorrectService,
        );

        // Remove the service ID from the list
        let index = service_organization.services_ids.index_of(&service_id);
        service_organization.services_ids.remove(index);

        // Remove the service from the table
        service_organization.services.remove(service_id); // Return Service has ability drop

        // Update package services
        update_package_services(service_organization_cap, organization_list, service_id);
    }

    fun get_service_organization(service_organization_cap: &ServiceOrganizationCap, organization_list: &mut OrganizationList): &mut ServiceOrganization {
        // the fact that `service_organization_cap` exists means that `organization_list` must own what it corresponds to
        // so we don’t need to judge here

        // get id
        let organization_id = object::id(service_organization_cap);
        // get and return service organization
        &mut organization_list.organizations[organization_id]
    }

    entry fun create_service(
        service_organization_cap: &ServiceOrganizationCap,
        organization_list: &mut OrganizationList,
        service_name: String,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let service_organization = get_service_organization(service_organization_cap, organization_list);

        // Generate a new ID for the service
        let service_id = object::id_from_address(ctx.fresh_object_address());

        // Create the Service struct
        let service = Service {
            service_name,
            price,
        };

        // Store the service in the organization
        service_organization.services.add(service_id, service);
        service_organization.services_ids.push_back(service_id);
    }

    fun update_package_services(
        service_organization_cap: &ServiceOrganizationCap,
        organization_list: &mut OrganizationList,
        service_id: ID,
    ) {
        let service_organization = get_service_organization(service_organization_cap, organization_list);

        let package_services_ids = &service_organization.package_services_ids;
        let package_services = &mut service_organization.package_services;

        let mut packages_to_destroy = vector[];

        // Iterate over package services and update prices
        for package_id in package_services_ids {
            let package_service = &mut package_services[*package_id];
            let services = &mut package_service.services;

            if services.contains(&service_id) {
                services.remove_value(&service_id);
                if services.length() < 2 {
                    packages_to_destroy.push_back(*package_id);
                } else {
                    let price_decrease = package_service.price / (services.length() + 1);
                    package_service.price = package_service.price - price_decrease;
                }
            }
        }

        // Destroy package services that no longer have enough services
        for package_id in packages_to_destroy {
            destroy_package_services(service_organization_cap, organization_list, package_id);
        }
    


    // Destroy package services that no longer have enough services
    for package_id in packages_to_destroy {
        destroy_package_services(service_organization_cap, organization_list, package_id);
    }

    }
    entry fun modify_package_services(
        service_organization_cap: &ServiceOrganizationCap,
        organization_list: &mut OrganizationList,
        package_id: ID,
        new_services: vector<ID>,
    ) {
        let service_organization = get_service_organization(service_organization_cap, organization_list);

        // Check if the package ID is valid
        assert!(
            service_organization.package_services_ids.contains(&package_id),
            ENotCorrectPackage,
        );

        // Check if all service IDs in the new_services vector are valid
        for service_id in &new_services {
            assert!(
                service_organization.services_ids.contains(service_id),
                ENotAllCorrectService,
            );
        }

        // Modify the services vector for the package
        let package_services = &mut service_organization.package_services[package_id];
        package_services.services = new_services;
    }
    entry fun modify_package_services_price(service_organization_cap: &ServiceOrganizationCap, organization_list: &mut OrganizationList, package_id: ID, price: u64) {
        // get ServiceOrganization
        let service_organization = get_service_organization(service_organization_cap, organization_list);

        // check package id
        assert!(service_organization.package_services_ids.contains(&package_id), ENotCorrectPackage);

        // modify price
        let package_services = &mut service_organization.package_services[package_id];
        package_services.price = price;
    }

    entry fun modify_package_service_and_price(service_organization_cap: &ServiceOrganizationCap, organization_list: &mut OrganizationList, package_id: ID, services: vector<ID>, price: u64) {
        modify_package_services(service_organization_cap, organization_list, package_id, services);
        modify_package_services_price(service_organization_cap, organization_list, package_id, price);
    }

    fun get_default_price(service_organization: &ServiceOrganization, services: &vector<ID>): u64 {
        let mut i = 0;
        let mut sum = 0;
        while (i < services.length()) {
            // get service id
            let id = services[i];
            // get service
            let service = &service_organization.services[id];
            // get price
            let price = service.price;
            // add
            sum = sum + price;
            i = i + 1;
        };
        // 85% off
        sum / 100 * 85
    }

    entry fun create_package_services(service_organization_cap: &ServiceOrganizationCap, organization_list: &mut OrganizationList, services: vector<ID>, ctx: &mut TxContext) {
        // get ServiceOrganization
        let service_organization = get_service_organization(service_organization_cap, organization_list);

        // get default price
        let default_price = get_default_price(service_organization, &services);

        create_package_services_and_price(service_organization_cap, organization_list, services, default_price, ctx);
    }

    entry fun create_package_services_and_price(service_organization_cap: &ServiceOrganizationCap, organization_list: &mut OrganizationList, services: vector<ID>, price: u64, ctx: &mut TxContext) {
        // get ServiceOrganization
        let service_organization = get_service_organization(service_organization_cap, organization_list);

        // generate new id
        let id = object::id_from_address(ctx.fresh_object_address());
        // init package serivces
        service_organization.package_services_ids.push_back(id);
        service_organization.package_services.add(id, PackageServices {
            services: vector<ID>[],
            price,
        });

        // store services
        modify_package_services(service_organization_cap, organization_list, id, services);
    }

    entry fun destroy_package_services(service_organization_cap: &ServiceOrganizationCap, organization_list: &mut OrganizationList, package_id: ID) {
        // get ServiceOrganization
        let service_organization = get_service_organization(service_organization_cap, organization_list);

        // check package id
        assert!(service_organization.package_services_ids.contains(&package_id), ENotCorrectPackage);

        // get index of `package_services_ids`
        let (_, index) = service_organization.package_services_ids.index_of(&package_id);
        // remove it
        service_organization.package_services_ids.remove(index);

        // package_services remove
        let PackageServices {
            mut services,
            price: _,
        } = service_organization.package_services.remove(package_id);
        // clear vector
        while (services.length() > 0) {
            services.pop_back();
        };
        // destroy vector
        services.destroy_empty();
    }

    // ====== get structure properties ======

    public fun borrow_organizations_ids(organization_list: &OrganizationList): &vector<ID> {
        &organization_list.organizations_ids
    }

    public fun borrow_organizations(organization_list: &OrganizationList): &Table<ID, ServiceOrganization> {
        &organization_list.organizations
    }

    public fun borrow_organizations_mut(organization_list: &mut OrganizationList): &mut Table<ID, ServiceOrganization> {
        &mut organization_list.organizations
    }

    public fun get_organization_name(organization: &ServiceOrganization): String {
        organization.organization_name
    }

    public fun borrow_services(organization: &ServiceOrganization): &Table<ID, Service> {
        &organization.services
    }

    public fun borrow_services_ids(organization: &ServiceOrganization): &vector<ID> {
        &organization.services_ids
    }

    public fun borrow_package_services(organization: &ServiceOrganization): &Table<ID, PackageServices> {
        &organization.package_services
    }

    public fun borrow_package_services_ids(organization: &ServiceOrganization): &vector<ID> {
        &organization.package_services_ids
    }

    public fun get_service_name(service: &Service): String {
        service.service_name
    }

    public fun get_service_price(service: &Service): u64 {
        service.price
    }

    public fun borrow_ids_from_package_services(package_services: &PackageServices): &vector<ID> {
        &package_services.services
    }

    public fun get_package_services_price(package_services: &PackageServices): u64 {
        package_services.price
    }

    // ====== balance consolidation ======

    public fun join_organization_balance(organization_list: &mut OrganizationList, organization_id: ID, balance: Balance<SUI>) {
        // get organization
        let organization = &mut organization_list.organizations[organization_id];
        // join
        organization.income.join(balance);
    }
}