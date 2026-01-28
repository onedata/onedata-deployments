const eoscplPink = '#F39BB1';
const eoscplTeal = '#257B85';

const customizerData = {
  /** @type {HTMLElement} */
  basicAuthButton: null,
  /** @type {HTMLElement} */
  accessEoscPlButton: null,
};
const buttonLabels = {
  accessEoscPl: 'Sign in with federated AAI',
  basicAuth: 'Sign in with username',
};
function getButtonAuthId(button) {
  for (const possibleId of ['accessEoscPl', 'basicAuth']) {
    if (button.classList.contains(possibleId)) {
      return possibleId;
    }
  }
}
function customizeFrontpage() {
  const { basicAuthButton, accessEoscPlButton } = customizerData;
  const buttonsContainer = document.querySelector('#login-buttons-container');
  
  // force button colors
  accessEoscPlButton.style.borderColor = eoscplPink;
  accessEoscPlButton.style.color = '#000';
  basicAuthButton.style.backgroundColor = 'white';
  basicAuthButton.style.borderColor = eoscplPink;
  basicAuthButton.style.color = '#000';

  // force auth button images matching to their colors
  /** @type {HTMLElement} */
  const basicAuthIcon = basicAuthButton.querySelector('.auth-icon-image');
  basicAuthIcon.style.backgroundImage =
    'url(./assets/basicauth.svg?rev=1769612656635)';
  
  // remover tip and apply button labels
  for (const button of buttonsContainer.querySelectorAll('.login-icon-box')) {
    const label = buttonLabels[getButtonAuthId(button)] || button.ariaLabel;
    const authIcon = button.querySelector('.auth-icon-image');
    authIcon.textContent = `${label}`;
    button.role = '';
    button.ariaLabel = '';
    button.dataset['microtipPosition'] = '';
  }

  // force basic auth button to be last button
  buttonsContainer.append(basicAuthButton);

  // show the button container when it is customized
  buttonsContainer.classList.remove('one-hidden');
}
const checkButtonsInterval = setInterval(() => {
  customizerData.basicAuthButton = document.querySelector('.login-icon-box.basicAuth');
  customizerData.accessEoscPlButton = document.querySelector('.login-icon-box.accessEoscPl');
  if (customizerData.basicAuthButton && customizerData.accessEoscPlButton) {
    clearInterval(checkButtonsInterval);
    customizeFrontpage();
  }
}, 100);