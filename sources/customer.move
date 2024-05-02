module ticketing_system::customer {
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::balance::Balance;
    use std::string::{Self, String};
    use sui::event;

    use ticketing_system::admin::OrganizationList;

    // ====== error code ======

    const ENotCorrectOrganizationID: u64 = 5;
    const ENotCorrectServiceID: u64 = 6;
    const ENotCorrectPackageServicesID: u64 = 7;
    const ENotEnoughCoin: u64 = 8;
    const ENotCorrectServicesList: u64 = 9;

    // ====== struct ======

    public struct ServiceCertification has key {
        id: UID,
        organization_id: ID,
        service_id: ID,
        purchase_price: Balance<SUI>,
    }

    public struct PackageServicesCertification has key {
        id: UID,
        organization_id: ID,
        package_services_id: ID,
        services: vector<ID>,
        purchase_price: Balance<SUI>,
    }

    public struct OrganizationListEvent has copy, drop {
        organization_name: String,
        organization_id: ID,
    }

    public struct ServiceEvent has copy, drop {
        service_name: String,
        service_id: ID,
    }

    public struct PackageServicesEvent has copy, drop {
        services: vector<String>,
        package_services_id: ID,
    }

    public struct RefundEvent has copy, drop {
        note: String,
        value: u64,
    }

    public struct EnjoyEvent has copy, drop {
        note: String,
    }

    // ====== function ======

    entry fun query_organization_list(organization_list: &OrganizationList) {
        // get organization ids
        let organization_ids = organization_list.borrow_organizations_ids();
        // get organizations
        let organizations = organization_list.borrow_organizations();
        
        let mut i = 0;
        while (i < organization_ids.length()) {
            // get organization_id
            let organization_id = organization_ids[i];
            // get organization
            let organization = &organizations[organization_id];
            // get organization_name
            let organization_name = organization.get_organization_name();

            // emit event
            event::emit(OrganizationListEvent {
                organization_name,
                organization_id,
            });

            i = i + 1;
        };
    }

    entry fun query_organization_services(organization_id: ID, organization_list: &OrganizationList) {
        // get organizations
        let organizations = organization_list.borrow_organizations();
        // get organization
        let organization = &organizations[organization_id];

        // get services
        let services = organization.borrow_services();
        // get services_ids
        let services_ids = organization.borrow_services_ids();
        
        let mut i = 0;
        while (i < services_ids.length()) {
            // get service is
            let service_id = services_ids[i];
            // get service
            let service = &services[service_id];
            // get service name
            let service_name = service.get_service_name();

            // emit event
            event::emit(ServiceEvent {
                service_name,
                service_id,
            });

            i = i + 1;
        };

        // get package services
        let package_services = organization.borrow_package_services();
        // get package services ids
        let package_services_ids = organization.borrow_package_services_ids();

        i = 0;
        while (i < package_services_ids.length()) {
            // get package_id
            let package_id = package_services_ids[i];
            // get package_services
            let package_services = &package_services[package_id];
            // get services(ids)
            let services_ids = package_services.borrow_ids_from_package_services();

            // init services names
            let mut services_names = vector<String>[];
            while (services_names.length() < services.length()) {
                // get index
                let idx = services_names.length();
                // get service id
                let service_id = services_ids[idx];
                // get service
                let service = &services[service_id];
                // get service name
                let service_name = service.get_service_name();
                // push back
                services_names.push_back(service_name);
            };

            // emit event
            event::emit(PackageServicesEvent {
                services: services_names,
                package_services_id: package_id,
            });

            i = i + 1;
        };
    }

    entry fun buy_service(organization_list: &OrganizationList, organization_id: ID, service_id: ID, mut sui: Coin<SUI>, ctx: &mut TxContext) {
        // get organizations
        let organizations = organization_list.borrow_organizations();
        // get organizations ids
        let organizations_ids = organization_list.borrow_organizations_ids();
        // check organization_id
        assert!(organizations_ids.contains(&organization_id), ENotCorrectOrganizationID);

        // get organization
        let organization = &organizations[organization_id];
        // get services
        let services = organization.borrow_services();
        // get services ids
        let services_ids = organization.borrow_services_ids();
        // check service_id
        assert!(services_ids.contains(&service_id), ENotCorrectServiceID);

        // get service
        let service = &services[service_id];
        // get price
        let price = service.get_service_price();
        // check coin amount
        assert!(sui.value() >= price, ENotEnoughCoin);

        // split coin
        let pay_coin = sui.split(price, ctx);

        // deal with the remaining coin
        if (sui.value() > 0) {
            transfer::public_transfer(sui, ctx.sender());
        } else {
            sui.destroy_zero();
        };

        // create ServiceCertification
        let service_certification = ServiceCertification {
            id: object::new(ctx),
            organization_id,
            service_id,
            purchase_price: pay_coin.into_balance(),
        };
        // tranfer it
        transfer::transfer(service_certification, ctx.sender());
    }

    fun check_organization_canceled(organization_id: &ID, organization_list: &OrganizationList): bool {
        // get organizations ids
        let organizations_ids = organization_list.borrow_organizations_ids();
        // not contains -> canceled -> return true
        !organizations_ids.contains(organization_id)
    }

    fun check_service_canceled(organization_id: ID, service_id: &ID, organization_list: &OrganizationList): bool {
        // get organizations
        let organizations = organization_list.borrow_organizations();
        // get organization
        let organization = &organizations[organization_id];
        // get services ids
        let services_ids = organization.borrow_services_ids();
        // not contains -> canceled -> return true
        !services_ids.contains(service_id)
    }

    fun check_package_services_canceled(organization_id: ID, package_services_id: &ID, organization_list: &OrganizationList): bool {
        // get organizations
        let organizations = organization_list.borrow_organizations();
        // get organization
        let organization = &organizations[organization_id];
        // get package_services_ids
        let package_services_ids = organization.borrow_package_services_ids();
        // not contains -> canceled -> return true
        !package_services_ids.contains(package_services_id)
    }

    #[allow(lint(self_transfer))]
    fun refund_canceled_package_services(organization_id: ID, organization_list: &OrganizationList, services: &mut vector<ID>, purchase_price: &mut Balance<SUI>, ctx: &mut TxContext) {
        // loop to find the canceled services
        let mut i = 0;
        let mut canceled_services = vector<ID>[];
        while (i < services.length()) {
            // get service_id
            let service_id = services[i];
            // check canceled and push back
            if (check_service_canceled(organization_id, &service_id, organization_list)) {
                canceled_services.push_back(service_id);
            };
            i = i + 1;
        };
        
        // get value
        let amount = purchase_price.value();
        // refund ratio = canceled_services.length() / services.length()
        // so we need to refund
        let need_to_refund = if (canceled_services.length() != services.length()) amount / services.length() * canceled_services.length() else amount;
        transfer::public_transfer(coin::take(purchase_price, need_to_refund, ctx), ctx.sender());

        // emit event
        event::emit(RefundEvent {
            note: string::utf8(b"some services have been canceled and funds have been refunded!"),
            value: need_to_refund,
        });

        // remove canceled services
        i = 0;
        while (i < canceled_services.length()) {
            let service_id = canceled_services[i];
            let (_, index) = services.index_of(&service_id);
            services.remove(index);
            i = i + 1;
        };
    }

    entry fun refund_service(service_certification: ServiceCertification, organization_list: &mut OrganizationList, ctx: &mut TxContext) {
        // deconstruct ServiceCertification
        let ServiceCertification {
            id,
            organization_id,
            service_id,
            mut purchase_price,
        } = service_certification;
        // delete id
        object::delete(id);

        // if the service organization has canceled, a direct refund will be issued
        // if the service has canceled, a direct refund will be issued
        if (check_organization_canceled(&organization_id, organization_list) || check_service_canceled(organization_id, &service_id, organization_list)) {
            event::emit(RefundEvent {
                note: string::utf8(b"service organization or service has canceled!"),
                value: purchase_price.value(),
            });
            transfer::public_transfer(coin::from_balance(purchase_price, ctx), ctx.sender());
            return
        };

        // for refunds due to your own reasons, a 10% fee will be charged
        let amount = purchase_price.value();
        // split
        let fee = purchase_price.split(amount / 10);
        organization_list.join_organization_balance(organization_id, fee);

        event::emit(RefundEvent {
            note: string::utf8(b"for refunds due to your own reasons, a 10% fee will be charged!"),
            value: purchase_price.value(),
        });

        // refunds
        transfer::public_transfer(coin::from_balance(purchase_price, ctx), ctx.sender());
    }

    entry fun enjoy_service(service_certification: ServiceCertification, organization_list: &mut OrganizationList, ctx: &mut TxContext) {
        // deconstruct ServiceCertification
        let ServiceCertification {
            id,
            organization_id,
            service_id,
            purchase_price,
        } = service_certification;
        // delete id
        object::delete(id);

        // if the service organization has canceled, a direct refund will be issued
        // if the service has canceled, a direct refund will be issued
        if (check_organization_canceled(&organization_id, organization_list) || check_service_canceled(organization_id, &service_id, organization_list)) {
            event::emit(RefundEvent {
                note: string::utf8(b"service organization or service has canceled!"),
                value: purchase_price.value(),
            });
            transfer::public_transfer(coin::from_balance(purchase_price, ctx), ctx.sender());
            return
        };

        // pay coin
        organization_list.join_organization_balance(organization_id, purchase_price);

        event::emit(EnjoyEvent {
            note: string::utf8(b"good morning, and in case i don't see you, good afternoon, good evening, and good night!"),
        });
    }
    
    entry fun buy_package_services(organization_list: &OrganizationList, organization_id: ID, package_services_id: ID, mut sui: Coin<SUI>, ctx: &mut TxContext) {
        // get organizations
        let organizations = organization_list.borrow_organizations();
        // get organizations ids
        let organizations_ids = organization_list.borrow_organizations_ids();
        // check organization_id
        assert!(organizations_ids.contains(&organization_id), ENotCorrectOrganizationID);

        // get organization
        let organization = &organizations[organization_id];
        // get package services
        let package_services = organization.borrow_package_services();
        // get package services ids
        let package_services_ids = organization.borrow_package_services_ids();
        // check package_services_id
        assert!(package_services_ids.contains(&package_services_id), ENotCorrectPackageServicesID);

        // get package_services
        let package_services_contents = &package_services[package_services_id];
        // get price
        let price = package_services_contents.get_package_services_price();
        // check coin amount
        assert!(sui.value() >= price, ENotEnoughCoin);

        // split coin
        let pay_coin = sui.split(price, ctx);

        // deal with the remaining coin
        if (sui.value() > 0) {
            transfer::public_transfer(sui, ctx.sender());
        } else {
            sui.destroy_zero();
        };

        // create PackageServiceCertification
        let package_services_certification = PackageServicesCertification {
            id: object::new(ctx),
            organization_id,
            package_services_id,
            services: *package_services_contents.borrow_ids_from_package_services(),
            purchase_price: pay_coin.into_balance(),
        };

        // transfer it
        transfer::transfer(package_services_certification, ctx.sender());
    }

    entry fun refund_package_services(package_services_certification: PackageServicesCertification, organization_list: &mut OrganizationList, ctx: &mut TxContext) {
        // deconstruct PackageServicesCertification
        let PackageServicesCertification {
            id,
            organization_id,
            package_services_id,
            mut services,
            mut purchase_price,
        } = package_services_certification;
        // delete id
        object::delete(id);

        // if the service organization has canceled, a direct refund will be issued
        // if the package_services has canceled, a direct refund will be issued
        if (check_organization_canceled(&organization_id, organization_list) || check_package_services_canceled(organization_id, &package_services_id, organization_list)) {
            event::emit(RefundEvent {
                note: string::utf8(b"service organization or package services has canceled!"),
                value: purchase_price.value(),
            });
            transfer::public_transfer(coin::from_balance(purchase_price, ctx), ctx.sender());

            while (services.length() > 0) {
                services.pop_back();
            };
            services.destroy_empty();

            return
        };

        // if the corresponding service has been cancelled, the corresponding amount will be refunded directly
        refund_canceled_package_services(organization_id, organization_list, &mut services, &mut purchase_price, ctx);

        // for refunds due to your own reasons, a 10% fee will be charged
        let amount = purchase_price.value();
        // split
        let fee = purchase_price.split(amount / 10);
        organization_list.join_organization_balance(organization_id, fee);

        event::emit(RefundEvent {
            note: string::utf8(b"for refunds due to your own reasons, a 10% fee will be charged!"),
            value: purchase_price.value(),
        });

        // refunds
        transfer::public_transfer(coin::from_balance(purchase_price, ctx), ctx.sender());
    }

    entry fun enjoy_package_services(package_services_certification: PackageServicesCertification, organization_list: &mut OrganizationList, ctx: &mut TxContext) {
        // deconstruct PackageServicesCertification
        let PackageServicesCertification {
            id,
            organization_id,
            package_services_id,
            services,
            purchase_price,
        } = package_services_certification;
        // delete id
        object::delete(id);

        // if the service organization has canceled, a direct refund will be issued
        // if the package_services has canceled, a direct refund will be issued
        if (check_organization_canceled(&organization_id, organization_list) || check_package_services_canceled(organization_id, &package_services_id, organization_list)) {
            event::emit(RefundEvent {
                note: string::utf8(b"service organization or package services has canceled!"),
                value: purchase_price.value(),
            });
            transfer::public_transfer(coin::from_balance(purchase_price, ctx), ctx.sender());
            return
        };

        // if the corresponding service has been cancelled, the corresponding amount will be refunded directly
        refund_canceled_package_services(organization_id, organization_list, &mut services.clone(), &mut Balance::from(purchase_price.value()), ctx);

        // pay coin
        organization_list.join_organization_balance(organization_id, purchase_price);

        event::emit(EnjoyEvent {
            note: string::utf8(b"good morning, and in case i don't see you, good afternoon, good evening, and good night!"),
        });
    }
}
