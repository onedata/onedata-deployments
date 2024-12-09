const egiBlue = '#005FAA';
const egiOrange = '#EF8200';
const customizerData = {
  /** @type {HTMLElement} */
  basicAuthButton: null,
  /** @type {HTMLElement} */
  egiButton: null,
};
const buttonLabels = {
  egi: 'Sign-in with EGI Check-in',
  basicAuth: 'Sign-in with username',
};
function getButtonAuthId(button) {
  for (const possibleId of ['egi', 'basicAuth']) {
    if (button.classList.contains(possibleId)) {
      return possibleId;
    }
  }
}
function customizeEgiFrontpage() {
  const { basicAuthButton, egiButton } = customizerData;
  const buttonsContainer = document.querySelector('#login-buttons-container');
  
  // force button colors
  egiButton.style.backgroundColor = egiBlue;
  egiButton.style.borderColor = egiBlue;
  egiButton.style.color = 'white';
  basicAuthButton.style.backgroundColor = 'transparent';
  basicAuthButton.style.borderColor = egiOrange;
  basicAuthButton.style.color = egiOrange;

  // force auth button images matching to their colors
  /** @type {HTMLElement} */
  const egiIcon = egiButton.querySelector('.auth-icon-image');
  egiIcon.style.backgroundImage = 'url(./assets/egi-logo-white.svg?rev=1733387933368)';
  /** @type {HTMLElement} */
  const basicAuthIcon = basicAuthButton.querySelector('.auth-icon-image');
  basicAuthIcon.style.backgroundImage =
    'url(./assets/basicauth-orange.svg?rev=1733387933368)';
  
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
  buttonsContainer.classList.remove('egi-hidden');
}
const checkButtonsInterval = setInterval(() => {
  customizerData.basicAuthButton = document.querySelector('.login-icon-box.basicAuth');
  customizerData.egiButton = document.querySelector('.login-icon-box.egi');
  if (customizerData.basicAuthButton && customizerData.egiButton) {
    clearInterval(checkButtonsInterval);
    customizeEgiFrontpage();
  }
}, 100);