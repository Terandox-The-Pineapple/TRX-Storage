if fs.exists("data") == false then shell.run("pastebin get LnvzL7ur data") end
if os.loadAPI("data") == false then error("Failed to load data API") end

local dictionary = {
    ["de"] = {
        --Shop System
        ["server_channel"] = "Server Kanal: ",
        ["terminal_channel"] = "Laden Kanal: ",
        ["shop_owner"] = "Ladenbesitzer: ",
        ["balance_chest_id"] = "Id der Geldkiste: ",
        ["channel_number"] = "Kanalnummer: ",
        ["payment_item_id"] = "Id der Waehrung (Standard = minecraft:diamond): ",
        ["payment_item_name"] = "Name der Waehrung (Standard = Diamant): ",
        ["payment_item_name_default"] = "Diamant",
        ["server_running"] = "Der Server läuft",
        ["command_input"] = "Befehle ( add, backup, init_disk ): ",
        ["run_initdisk_first"] = "Bitte führe zuerst init_disk aus!!!",
        ["is_not_valid_option"] = " ist keine gültige Option!!!",
        ["add_itemlist_entry"] = "Füge Itemlisten-Eintrag hinzu",
        ["item_name"] = "Itemname: ",
        ["item_category"] = "Item Kategorie: ",
        ["amount_per_sell"] = "Anzahl pro Verkauf: ",
        ["price_per_sell"] = "Preis pro Verkauf: ",
        ["storage_id"] = "Id der Lagerkiste: ",
        ["not_valid_number_amount_price"] = "Eingabe für Anzahl oder Preis ist nicht gültig!!!",
        ["entry_saved_disk"] = "Listeneintrag auf Diskette gespeichert",
        ["copied_files_success"] = "Dateien erfolgreich kopiert!!!",
        ["disk_already_initialized"] = "Die Diskette ist bereits initialisiert!!!",
        ["disk_initialized_success"] = "Diskette erfolgreich initialisiert!!!",
        -- One string (No disk in left/right disk drive!!!)
        ["no_disk_in"] = "Keine Diskette im ",
        ["no_disk_left"] = "linken",
        ["no_disk_right"] = "rechten",
        ["no_disk_disk_drive"] = " Laufwerk gefunden!!!",
        -- String ends here
        --Storage System
        ["send_to_storage"] = "Einlagern",
        ["home_menu"] = "Hauptmenü",
        ["search"] = "Suchen",
        ["get_count"] = "Anzahl",
        ["request"] = "Anfordern",
        ["turtles"] = "Turtles",
        ["view_que"] = "Querry",
        ["ping"] = "Ping",
        ["craft"] = "Herstellen",
        ["new_recipes"] = "Neue Rezepte",
        ["reload"] = "Neu Laden",
        ["add_recipe"] = "Rezept hinzufügen",
        ["count"] = "Anzahl",
        ["status"] = "Status",
        ["que"] = "Querry",
        ["result"] = "Ergebnis",
        ["search_recipes"] = "Rezept Suchen:",
        ["create_recipe"] = "Rezept erstellen:",
        ["recipe_saved"] = "Rezept gespeichert",
        ["recipe_not_exist"] = "Rezept existiert nicht",
        ["name_of_output_chest"] = "Name der Ausgangs-Truhe: ",
        ["name_of_crafting_dropper"] = "Name des Crafting-Droppers: ",
        ["start_counting_all_items"] = "Erstelle Inventarliste",
        ["listed_all_items"] = "Inventarliste erstellt",
        ["item_not_found"] = "Item konnte nicht im System gefunden werden",
        ["no_turtle_idle"] = "Keine Turtle ist Idle",
        ["request_not_possible"] = "Auftrag nicht ausführbar",
        ["start_crafting"] = "Beginne Herstellung",
        ["crafting_finished"] = "Herstellung beendet",
        ["item_request"] = "Items angefordert: ",
        ["adding_recipe"] = "Füge Rezept hinzu: ",
        ["connected"] = "Verbunden : ",
        ["turtle_connection_denied"] = "Turtle-Verbindung verweigert",
        ["ended_gracefully"] = "Programm beendet",
        ["connection_denied"] = "Verbindung verweigert!!!",
        ["ping_not_answered"] = "Der Ping wurde nicht beantwortet. Vers: "
    },
    ["en"] = {
        --Shop System
        ["server_channel"] = "Server channel: ",
        ["terminal_channel"] = "Terminal channel: ",
        ["shop_owner"] = "Shop Owner: ",
        ["balance_chest_id"] = "Balance chest id: ",
        ["channel_number"] = "Channel number: ",
        ["payment_item_id"] = "Payment item id (default = minecraft:diamond): ",
        ["payment_item_name"] = "Payment item name (default = Diamond): ",
        ["payment_item_name_default"] = "Diamond",
        ["server_running"] = "Server is running",
        ["command_input"] = "Command ( add, backup, init_disk ): ",
        ["run_initdisk_first"] = "Please run init_disk first!!!",
        ["is_not_valid_option"] = " is not an valid option!!!",
        ["add_itemlist_entry"] = "Add itemlist entry",
        ["item_name"] = "Item name: ",
        ["item_category"] = "Item category: ",
        ["amount_per_sell"] = "Amount per sell: ",
        ["price_per_sell"] = "Price per sell: ",
        ["storage_id"] = "Storage chest id: ",
        ["not_valid_number_amount_price"] = "Not a valid number for amount or price!!!",
        ["entry_saved_disk"] = "List entry saved to disk",
        ["copied_files_success"] = "Copied files successfully!!!",
        ["disk_already_initialized"] = "Disk is already initialized!!!",
        ["disk_initialized_success"] = "Disk initialized successfully!!!",
        -- One string (No disk in left/right disk drive!!!)
        ["no_disk_in"] = "No disk in ",
        ["no_disk_left"] = "left",
        ["no_disk_right"] = "right",
        ["no_disk_disk_drive"] = " disk drive!!!",
        -- String ends here
        --Storage System
        ["send_to_storage"] = "Send to Storage",
        ["home_menu"] = "Home",
        ["search"] = "Search",
        ["get_count"] = "Get Count",
        ["request"] = "Request",
        ["turtles"] = "Turtles",
        ["view_que"] = "View Que",
        ["ping"] = "Ping",
        ["craft"] = "Craft",
        ["new_recipes"] = "New recipes",
        ["reload"] = "Reload",
        ["add_recipe"] = "Add recipe",
        ["count"] = "Count",
        ["status"] = "Status",
        ["que"] = "Que",
        ["result"] = "Result",
        ["search_recipes"] = "Search recipes:",
        ["create_recipe"] = "Create recipe:",
        ["recipe_saved"] = "Recipe Saved",
        ["recipe_not_exist"] = "Recipe does not exist",
        ["name_of_output_chest"] = "Name of Output Chest: ",
        ["name_of_crafting_dropper"] = "Name of Crafting Dropper: ",
        ["start_counting_all_items"] = "Start counting all Items",
        ["listed_all_items"] = "Listed all Items",
        ["item_not_found"] = "item not found in system",
        ["no_turtle_idle"] = "No Turtle is Idle",
        ["request_not_possible"] = "Request not possible",
        ["start_crafting"] = "Start Crafting",
        ["crafting_finished"] = "crafting finished",
        ["item_request"] = "Item request: ",
        ["adding_recipe"] = "Adding recipe: ",
        ["connected"] = "Connected : ",
        ["turtle_connection_denied"] = "Turtle-Connection Denied",
        ["ended_gracefully"] = "ENDED GRACEFULLY",
        ["connection_denied"] = "Connection Denied!!!",
        ["ping_not_answered"] = "Ping was not answered. Rep: "
    }
}

local dicVersion = 1.1

if data.get("dictionary","dictionary") == nil or data.get("version","dictionary") == nil or tonumber(data.get("version","dictionary")) < dicVersion then
    local dicdata = textutils.serialise(dictionary)
    data.set("dictionary", dicdata,"dictionary")
    data.set("version", dicVersion,"dictionary")
    print("Dictionary updated successful!!!")
end

return true