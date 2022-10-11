$(function() {
    
    let canSwitchImage = true;
    let selectedProperty;
    let propertyBuying;
    let properties = [];
    let manage = false;
    let buying;
    let owned;

    $(".buyCon").click(function() {
        $(".buyConfirmation").hide();
        $.post(`https://${GetParentResourceName()}/checkAccount`, JSON.stringify({
            id: properties[propertyBuying].id
        }));
        $.post(`https://${GetParentResourceName()}/sound`);
    });
    $(".buyCan").click(function() {
        $(".buyConfirmation").hide();
        $(".buyInfo").fadeIn("fast");
        $.post(`https://${GetParentResourceName()}/sound`);
    });

    $("#close").click(function() {
        $(".page").fadeOut();
        $.post(`https://${GetParentResourceName()}/close`);
        $.post(`https://${GetParentResourceName()}/sound`);
        $(".properties").empty();
    });

    $("#manage").click(function() {
        if (manage) {
            loadProperties();
        } else {
            $.post(`https://${GetParentResourceName()}/manage`);
        };
        $.post(`https://${GetParentResourceName()}/sound`);
    });

    $(".buyReturn").click(function() {
        $(".buySuccessful").fadeOut();
        $(".buyFailed").fadeOut();
        $(".buyInfo").fadeIn("fast");
        $.post(`https://${GetParentResourceName()}/sound`);
    });

    $(".manageAccessAdd").click(function() {
        const user = $(".inputAccess").find(":selected").data("serverid");
        if (user) {
            $.post(`https://${GetParentResourceName()}/sound`);
            $.post(`https://${GetParentResourceName()}/grantAccess`, JSON.stringify({
                id: user,
                property: owned[selectedProperty].propertyid
            }));
        };
    });

    function manageProperties(ownedProperties, refresh) {
        owned = ownedProperties;
        manage = true;
        $(".buyInfo, .buyConfirmation, .buySuccessful, .buyFailed").hide();
        $(".properties").empty();

        if (ownedProperties.length == 0) {
            $(".info-empty").show();
            return;
        };

        $(".info-manage").show();
        $(".info-hasAccess").empty();
        if (!refresh) {
            selectedProperty = ownedProperties.length - 1
        };

        $(".inputAccess").empty();
        $(".inputAccess").append(`<option value="" disabled selected>Select a player</option>`);
        for (const [_, value] of Object.entries(ownedProperties[selectedProperty].players)) {
            $(".inputAccess").append(`<option data-serverid="${value.id}">${value.name}</option>`);
        };

        for (const [key, value] of Object.entries(ownedProperties)) {
            $(".properties").prepend(`
                <div class="property" data-number="${key}">
                    <div class="propertyImageContainer">
                        <img class="propertyImage" src="${value.images[0]}" data-propertynumber="${key}" data-imagenumber="0">
                    </div>
                    <p class="propertyLocation">${value.address}</p>
                </div>
            `);
        };

        for (const [_, value] of Object.entries(ownedProperties[selectedProperty].hasAccess)) {
            $(".info-hasAccess").append(`
                <div class="accessUser">
                    <p class="accessUser-name">${value.name}</p><button class="accessUser-remove" data-character="${value.character}" data-property="${ownedProperties[selectedProperty].propertyid}">Remove</button>
                </div>
            `);
        };

        $(".propertyImage").click(function() {
            const number = $(this).data("propertynumber");
            if (selectedProperty == number) {return};
            selectedProperty = number;

            $(".inputAccess").empty();
            $(".inputAccess").append(`<option value="" disabled selected>Select a player</option>`);
            for (const [_, value] of Object.entries(ownedProperties[selectedProperty].players)) {
                $(".inputAccess").append(`<option data-serverid="${value.id}">${value.name}</option>`);
            };

            $(".info-hasAccess").empty();
            for (const [_, value] of Object.entries(ownedProperties[selectedProperty].hasAccess)) {
                $(".info-hasAccess").append(`
                    <div class="accessUser">
                        <p class="accessUser-name">${value.name}</p><button class="accessUser-remove" data-character="${value.character}" data-property="${ownedProperties[selectedProperty].propertyid}">Remove</button>
                    </div>
                `);
            };

            $(".accessUser-remove").click(function() {
                const user = $(this).data("character");
                if (user) {
                    $.post(`https://${GetParentResourceName()}/sound`);
                    $.post(`https://${GetParentResourceName()}/removeAccess`, JSON.stringify({
                        character: user,
                        property: ownedProperties[selectedProperty].propertyid
                    }));
                };
            });
        });

        $(".accessUser-remove").click(function() {
            const user = $(this).data("character");
            if (user) {
                $.post(`https://${GetParentResourceName()}/sound`);
                $.post(`https://${GetParentResourceName()}/removeAccess`, JSON.stringify({
                    character: user,
                    property: ownedProperties[selectedProperty].propertyid
                }));
            };
        });
    };

    function loadProperties(update) {
        manage = false
        $(".properties").empty();
        $(".info-manage, .info-empty").hide();
        if (!update) {
            $(".buyConfirmation").hide();
            $(".buyInfo").fadeIn("fast");
        }
        const firstProperty = properties.length - 1;
        selectedProperty = firstProperty;
        $(".buyInfo-desc").text(properties[firstProperty].desc);
        $(".buyInfo-bigImage").attr("src", properties[firstProperty].images[0]);
        $(".buyInfo-images").empty();
        for (const [key, value] of Object.entries(properties[firstProperty].images)) {
            if (key == 0) {
                $(".buyInfo-bigImage").attr("src", value);
                $(".buyInfo-images").append(`<img class="buyInfo-imagesImage" src="${value}" data-imagenumber="${key}" data-propertynumber="${firstProperty}" style="opacity: 1;">`);
            } else {
                $(".buyInfo-images").append(`<img class="buyInfo-imagesImage" src="${value}" data-imagenumber="${key}" data-propertynumber="${firstProperty}">`);
            };
        };
        $(".buyInfo-imagesImage").click(function() {
            if (!canSwitchImage) {return};
            $(".buyInfo-imagesImage").css("opacity", "0.6");
            $(this).css("opacity", "1");
            const pnumber = $(this).data("propertynumber");
            const inumber = $(this).data("imagenumber");
            if ($(".buyInfo-bigImage").attr("src") == properties[pnumber].images[inumber]) {return};
            canSwitchImage = false;
            $(".buyInfo-bigImage").css("opacity", "0");
            setTimeout(() => {
                $(".buyInfo-bigImage").attr("src", properties[pnumber].images[inumber]);
                $(".buyInfo-bigImage").css("opacity", "1");
                canSwitchImage = true;
            }, 150);
        });
        for (const [key, value] of Object.entries(properties)) {
            if (value && value.price) {
                $(".properties").prepend(`
                    <div class="property" data-number="${key}">
                        <div class="propertyImageContainer">
                            <img class="propertyImage" src="${value.images[0]}" data-propertynumber="${key}" data-imagenumber="0">
                        </div>
                        <p class="propertyLocation">${value.location}</p>
                        <p class="propertyPrice">$${value.price}</p><button class="propertyBuy" data-propertynumber="${key}">Buy</button>
                    </div>
                `);
            };
        };
        $(".propertyImage").click(function() {
            const number = $(this).data("propertynumber");
            if (selectedProperty == number) {return};
            selectedProperty = number;
            $(".buyConfirmation").hide();
            $(".buyInfo").fadeIn("fast");
            $(".buyInfo-desc").text(properties[number].desc);
            $(".buyInfo-bigImage").attr("src", properties[number].images[0]);
            $(".buyInfo-images").empty();
            for (const [key, value] of Object.entries(properties[number].images)) {
                if (key == 0) {
                    $(".buyInfo-bigImage").attr("src", value);
                    $(".buyInfo-images").append(`<img class="buyInfo-imagesImage" src="${value}" data-imagenumber="${key}" data-propertynumber="${number}" style="opacity: 1;">`);
                } else {
                    $(".buyInfo-images").append(`<img class="buyInfo-imagesImage" src="${value}" data-imagenumber="${key}" data-propertynumber="${number}">`);
                };
            };

            $(".buyInfo-imagesImage").click(function() {
                if (!canSwitchImage) {return};
                $(".buyInfo-imagesImage").css("opacity", "0.6");
                $(this).css("opacity", "1");
                const pnumber = $(this).data("propertynumber");
                const inumber = $(this).data("imagenumber");
                if ($(".buyInfo-bigImage").attr("src") == properties[pnumber].images[inumber]) {return};
                canSwitchImage = false;
                $(".buyInfo-bigImage").css("opacity", "0");
                setTimeout(() => {
                    $(".buyInfo-bigImage").attr("src", properties[pnumber].images[inumber]);
                    $(".buyInfo-bigImage").css("opacity", "1");
                    canSwitchImage = true;
                }, 150);
            });
        });

        $(".propertyBuy").click(function() {
            buying = $(this);
            propertyBuying = buying.data("propertynumber");
            $(".buyInfo, .buySuccessful, .buyFailed").hide();
            $(".buyConfirmation").fadeIn("fast");
            $.post(`https://${GetParentResourceName()}/sound`);
        });
    };

    window.addEventListener("message", function(event) {
        const item = event.data;
        if (item.type === "display") {
            if (item.status) {
                properties = JSON.parse(item.properties);
                loadProperties();
                $(".page").fadeIn();
            } else {
                $(".page").fadeOut();
            };
        };

        if (item.type === "manage") {
            manageProperties(JSON.parse(item.propertiesManage));
        };

        if (item.type === "refreshAccess") {
            manageProperties(JSON.parse(item.propertiesManage), true);
        };

        if (item.type === "update") {
            properties = JSON.parse(item.properties);
            loadProperties(true);
        };

        if (item.type === "purchase") {
            if (item.success) {
                $(".buySuccessful").fadeIn("fast");
            } else {
                $(".buyFailed").fadeIn("fast");
            };
        };
    });

    window.addEventListener("keydown", (event) => {
        if (event.defaultPrevented) {
            return; // Do nothing if the event was already processed
        };

        if (event.key == "Escape") {
            $(".page").fadeOut();
            $.post(`https://${GetParentResourceName()}/close`);
        };
      
        // Cancel the default action to avoid it being handled twice
        event.preventDefault();
    }, true);

});