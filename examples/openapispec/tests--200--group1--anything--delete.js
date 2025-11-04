pm.test("DELETE /anything: Request status code is 200", () => {
    pm.response.to.have.status(200);
});
