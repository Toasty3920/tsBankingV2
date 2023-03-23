$(function () {
    let type            = null
    let inputValue      = null
    let transferToValue = null
    let transfer        = null

    window.addEventListener('message', function(event) {
        let item = event.data

        let playerName = item.playerName
        let moneyAmount = item.money
        let bankAmount = item.accountmoney
        let iban = item.cardnumber
        let amount = item.amount

        transfer = {
            type : item.transferType,
            state: item.transferState,
        }

        if (item.type == "openATMMenu") {
            $("body, html, .main").css("display", "flex")

            if (Config.SoundsActivated) {
                playLoginSound()
            }
        } else if (item.type == "closeATMMenu") {
            $("body, html, .main, .keyboard-wrapper, .createAccountnumber-wrapper").css("display", "none")
        }

        if (item.type == "getPlayerData") {
            $(".accountname, .name").html(playerName)
            $(".money").html(moneyAmount)
            $(".bank").html(bankAmount)
            $(".bankid").html(iban)
        }

        if (item.type == "createNewIBAN") {
            $("body, html").css("display", "flex")
            $(".createAccountnumber-wrapper").css("display", "flex")
            $(".main").css("display", "none")
        } else if (item.type == "setPlayerIBAN") {
            $(".bankid").html(iban)
        }

        if (item.type == "deposit") {
            $(".transactions-content").append(`
                <div class="transaction-item">
                    <div class="transaction-item-icon-wrapper" data-type="`+ type +`">
                        <i class="green fa-solid fa-plus plus"></i>
                    </div>
                    <h3 class="transaction-item-type">Einzahlung</h3>
                    <h3 class="transaction-item-amount"><span class="green">+</span><span class="green transaction-amount">` + amount + `</span><span class="green">$</span></h3>
                </div>
            `);
        } else if (item.type == "withdraw") {
            $(".transactions-content").append(`
                <div class="transaction-item">
                    <div class="transaction-item-icon-wrapper" data-type="`+ type +`">
                        <i class="red fa-solid fa-minus minus"></i>
                    </div>
                    <h3 class="transaction-item-type">Auszahlung</h3>
                    <h3 class="transaction-item-amount"><span class="red">-</span><span class="red transaction-amount">` + amount + `</span><span class="red">$</span></h3>
                </div>
            `);
        } else if (item.type == "transfer") {
            if (transfer.type == "TransferPossible" && transfer.state == true) {
                $(".transactions-content").append(`
                    <div class="transaction-item">
                        <div class="transaction-item-icon-wrapper" data-type="`+ type +`">
                            <i class="orange fa-solid fa-right-left arrows"></i>
                        </div>
                        <h3 class="transaction-item-type">Überweisung</h3>
                        <h3 class="transaction-item-amount"><span class="orange">-</span><span class="orange transaction-amount">` + amount + `</span><span class="orange">$</span></h3>
                    </div>
                `);
            }
        }

        $("button").click(function(){
            playClickSound()
        });
    });

    // NAVBAR BUTTONS
    $(".home-button").click(function(e) {
        e.preventDefault();

        $(".current-headline").html(Config.HomepageOptions.Headline)
        $(".fastdeposit-buttons-wrapper, .fastwithdraw-buttons-wrapper, .change-accountnumber-wrapper").css("display", "none")
        
        $(".home-button").css("background", "var(--button-color)")
        $(".home-icon").css("color", "#fff")
        
        $(".transactions-button, .settings-button").css("background", "transparent")
        $(".transfer-icon, .settings-icon").css("color", "var(--icon-color)")
        
        $(".balance-wrapper, .transactions-wrapper, .account-interactions-wrapper").css("display", "block")
        $.post('https://tsBankingV2/balance', JSON.stringify({}));
    });

    $(".transactions-button").click(function(e) {
        e.preventDefault();
        
        $(".current-headline").html(Config.TransactionOptions.Headline)
        $(".balance-wrapper, .transactions-wrapper, .account-interactions-wrapper, .change-accountnumber-wrapper, .keyboard-wrapper").css("display", "none")

        $(".transactions-button").css("background", "var(--button-color)")
        $(".transfer-icon").css("color", "#fff")

        $(".home-button, .settings-button").css("background", "transparent")
        $(".home-icon, .settings-icon").css("color", "var(--icon-color)")

        $(".fastdeposit-buttons-wrapper, .fastwithdraw-buttons-wrapper").css("display", "flex")
    });

    $(".settings-button").click(function(e) {
        e.preventDefault();

        $(".current-headline").html(Config.SettingsOptions.Headline)
        $(".balance-wrapper, .transactions-wrapper, .account-interactions-wrapper, .fastdeposit-buttons-wrapper, .fastwithdraw-buttons-wrapper, .keyboard-wrapper").css("display", "none")
        
        $(".settings-button").css("background", "var(--button-color)")
        $(".settings-icon").css("color", "#fff")

        $(".home-button, .transactions-button").css("background", "transparent")
        $(".home-icon, .transfer-icon").css("color", "var(--icon-color)")
        
        $(".change-accountnumber-wrapper").css("display", "block")
    });

    // ACCOUNT INTERACTION BUTTONS AND TEXTS
    $(".deposit").click(function(e) {
        e.preventDefault();

        $(".keyboard-headline").html(Config.KeyboardSettings.Deposit.Headline)
        $(".keyboard-wrapper").css("display", "flex")
        type = "deposit"

        $(".keyboard-input").val('')
    });

    $(".withdraw").click(function(e) {
        e.preventDefault();

        $(".keyboard-headline").html(Config.KeyboardSettings.Withdraw.Headline)
        $(".keyboard-wrapper").css("display", "flex")
        type = "withdraw"

        $(".keyboard-input").val('')
    });

    $(".transfer").click(function(e) {
        e.preventDefault()

        $(".keyboard-headline").html(Config.KeyboardSettings.Transfer.Headline)
        $(".user-input").css("display", "flex")
        $(".keyboard-wrapper").css("display", "flex")
        type = "transfer"

        $(".user-input").val('')
        $(".keyboard-input").val('')
    });

    // KEYBOARD ONCLICK EVENTS
    $(".submit").click(function(e) {
        e.preventDefault();

        if (type == "deposit") {
            $(".keyboard-wrapper, .user-input").css("display", "none")
            inputValue = $(".keyboard-input").val()

            $.post('https://tsBankingV2/deposit', JSON.stringify({
                amount: inputValue,
            }));
            $.post('https://tsBankingV2/balance', JSON.stringify({}));

            $(".keyboard-input").val('')
            inputValue = null
        } else if (type == "withdraw") {
            $(".keyboard-wrapper, .user-input").css("display", "none")
            inputValue = $(".keyboard-input").val()

            $.post('https://tsBankingV2/withdraw', JSON.stringify({
                amount: inputValue,
            }));
            $.post('https://tsBankingV2/balance', JSON.stringify({}));

            $(".keyboard-input").val('')
            inputValue = null
        } else if (type == "transfer") {
            $(".keyboard-wrapper, .user-input").css("display", "none")
            inputValue = $(".keyboard-input").val()
            transferToValue = $(".user-input").val()

            $.post('https://tsBankingV2/transfer', JSON.stringify({
                amount: inputValue,
                banknumber: transferToValue,
            }));
            $.post('https://tsBankingV2/balance', JSON.stringify({}));

            $(".keyboard-input").val('')
            $(".user-input").val('')
            inputValue = null
            transferToValue = null
        }
    });

    $(".keyboard-button").click(function() {
        let number = $(this).html()
        addNumber(number)
    });

    $(".delete").click(function() {
        deleteNumber()
    });

    $(".fastdeposit-button").click(function() {
        let value = $(this).children().html()

        $.post('https://tsBankingV2/deposit', JSON.stringify({
            amount: value,
        }));
        $.post('https://tsBankingV2/balance', JSON.stringify({}))
    });

    $(".fastwithdraw-button").click(function() {
        let value = $(this).children().html()

        $.post(`https://tsBankingV2/withdraw`, JSON.stringify({
            amount: value,
        }));
        $.post('https://tsBankingV2/balance', JSON.stringify({}))
    });

    // IBAN CREATION EVENT
    $(".createAccountnumber-button").click(function() {
        $("body, html, .main").css("display", "flex")
        $(".createAccountnumber-wrapper").css("display", "none")
        $.post('https://tsBankingV2/registerAccountNumber', JSON.stringify({}));

        setTimeout(() => {
            $.post('https://tsBankingV2/setAccountNumber', JSON.stringify({}));
        }, 2500);
    });

    // CHANGE IBAN EVENT
    $(".change-accountnumber-submit-button").click(function() {
        let newAccountnumber = $(".change-accountnumber-input").val()

        $.post('https://tsBankingV2/changeAccountNumber', JSON.stringify({
            newAccountnumber: newAccountnumber,
        }));

        $(".change-accountnumber-input").val(Config.AccountnumberPrefix)

        setTimeout(() => {
            $.post('https://tsBankingV2/setAccountNumber', JSON.stringify({}));
        }, 2500);
    });

    /*
    -------------------------
    ---   TEXT SETTINGS   ---
    -------------------------
    */

    // HEADLINES SETTINGS
    $(".balance-headline").html(Config.HomepageOptions.AccountInfoHeadline)
    $(".account-interaction-headline").html(Config.HomepageOptions.AccountInteractionHeadline)
    $(".transactions-headline").html(Config.HomepageOptions.TransactionHeadline)

    $(".change-accountnumber-headline").html(Config.SettingsOptions.ChangeAccountnumberHeadline)

    // FASTDEPOSIT AND FASTWITHDRAW SETTINGS
    $(".fastdeposit-headline").html(Config.FastDepositSettings.Headline)
    $(".fastdepositAmount1").html(Config.FastDepositSettings.Amount1)
    $(".fastdepositAmount2").html(Config.FastDepositSettings.Amount2)
    $(".fastdepositAmount3").html(Config.FastDepositSettings.Amount3)
    $(".fastdepositAmount4").html(Config.FastDepositSettings.Amount4)

    $(".fastwithdraw-headline").html(Config.FastWithdrawSettings.Headline)
    $(".fastwithdrawAmount1").html(Config.FastWithdrawSettings.Amount1)
    $(".fastwithdrawAmount2").html(Config.FastWithdrawSettings.Amount2)
    $(".fastwithdrawAmount3").html(Config.FastWithdrawSettings.Amount3)
    $(".fastwithdrawAmount4").html(Config.FastWithdrawSettings.Amount4)

    // MENUBAR BUTTON TEXTS
    $("#home-button").html(Config.MenuBarSettings.OverviewButtonHeadline)
    $("#transactions-button").html(Config.MenuBarSettings.TransactionsButtonHeadline)
    $("#settings-button").html(Config.MenuBarSettings.SettingsButtonHeadline)

    // CHANGE ACCOUNTNUMBER TEXTS
    $(".change-accountnumber-input").val(Config.AccountnumberPrefix)
    $(".change-accountnumber-text").html(Config.SettingsOptions.ChangeAccountnumberText)

    // OTHER TEXT SETTINGS
    $("#logout-button").html(Config.HomepageOptions.LogoutbuttonHeadline)

    // FUNCTIONS
    function addNumber(number) {
        document.querySelector(".keyboard-input").value += number
    }

    function deleteNumber() {
        document.querySelector(".keyboard-input").value = $(".keyboard-input").val().slice(0, -1)
    }

    function playLoginSound() {
        let loginSound = document.querySelector('#loginSound')
        loginSound.volume = Config.AudioVolume
        loginSound.play()
    }

    function playClickSound() {
        let clickSound = document.querySelector('#clickSound')
        clickSound.volume = Config.AudioVolume
        clickSound.play()
    }

    // OTHER ONCLICK METHODS
    $(".logout-button").click(function() {
        $.post('https://tsBankingV2/close', JSON.stringify({}))
    });

    // ON ESC PRESS CLOSE MENU
    document.onkeyup = function(data) {
        if (data.which == 27) {
            $.post(`https://tsBankingV2/close`, JSON.stringify({}));
        }
    }
});
