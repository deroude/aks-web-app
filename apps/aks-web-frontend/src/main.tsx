import {StrictMode} from 'react';
import * as ReactDOM from 'react-dom/client';
import {BrowserRouter} from 'react-router-dom';
import {AuthProvider} from "react-oidc-context";

import App from './app/app';

const oidcConfig = {
  authority: "https://node-seed.eu.auth0.com/",
  client_id: "qrPpGPIQXawU9bpWg64frEXIEOSb9mkX",
  redirect_uri: window.location.origin,
  // ...
};

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <StrictMode>
    <BrowserRouter>
      <AuthProvider {...oidcConfig}>
        <App/>
      </AuthProvider>
    </BrowserRouter>
  </StrictMode>
);
