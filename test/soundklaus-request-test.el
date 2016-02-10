(require 'ert)
(require 'soundklaus-request)

(ert-deftest soundklaus-request-headers-test ()
  (let ((request (soundklaus-make-request "/tracks")))
    (should (equal (soundklaus-request-headers request)
                   '(("Accept" . "application/json"))))))

(ert-deftest soundklaus-request-method-test ()
  (let ((request (soundklaus-make-request "/tracks")))
    (should (equal (soundklaus-request-method request) "GET"))))

(ert-deftest soundklaus-request-scheme-test ()
  (let ((request (soundklaus-make-request "/tracks")))
    (should (equal (soundklaus-request-scheme request) 'https))))

(ert-deftest soundklaus-request-server-name-test ()
  (let ((request (soundklaus-make-request "/tracks")))
    (should (equal (soundklaus-request-server-name request) "api.soundcloud.com"))))

(ert-deftest soundklaus-request-server-port-test ()
  (let ((request (soundklaus-make-request "/tracks")))
    (should (equal (soundklaus-request-server-port request) 443))))

(ert-deftest soundklaus-request-uri-test ()
  (let ((request (soundklaus-make-request "/tracks")))
    (should (equal (soundklaus-request-uri request) "/tracks"))))

(ert-deftest soundklaus-request-query-params-test ()
  (let ((request (soundklaus-make-request "/tracks")))
    (should (equal (soundklaus-request-query-params request)
                   `((client_id ,soundklaus-client-id)
                     (oauth_token ,soundklaus-access-token))))))

(ert-deftest soundklaus-request-url-test ()
  (let ((request (soundklaus-make-request "/tracks")))
    (should (equal (soundklaus-request-url request)
                   "https://api.soundcloud.com:443/tracks?client_id=988875d70be466a2dd1bfab120c0a306"))))

(ert-deftest soundklaus-send-sync-request-test ()
  (let* ((request (soundklaus-make-request "/tracks"))
         (response (soundklaus-send-sync-request request)))
    (should (vectorp response))))

(ert-deftest soundklaus-next-request-test ()
  (let* ((request (soundklaus-make-request "/tracks"))
	 (next (soundklaus-next-request request))
	 (params (soundklaus-request-query-params next)))
    (should (equal 10 (cdr (assoc "limit" params))))
    (should (equal 10 (cdr (assoc "offset" params)))))
  (let* ((request (soundklaus-make-request "/tracks" :query-params '(("offset" . 10))))
	 (next (soundklaus-next-request request))
	 (params (soundklaus-request-query-params next)))
    (should (equal 10 (cdr (assoc "limit" params))))
    (should (equal 20 (cdr (assoc "offset" params)))))
  (let* ((request (soundklaus-make-request "/tracks" :query-params '(("limit" . 5) ("offset" . 20))))
	 (next (soundklaus-next-request request))
	 (params (soundklaus-request-query-params next)))
    (should (equal 5 (cdr (assoc "limit" params))))
    (should (equal 25 (cdr (assoc "offset" params))))))

(provide 'soundklaus-request-test)