import XCTest
import RxSwift
import RxTest
@testable import foyer

class FoyerClientTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var foyerClient: FoyerClient!
    private var networkerSpy: NetworkerSpy!

    private let output_user = TestObserver<AppUser?>()

    override func setUp() {
        disposeBag = DisposeBag()
        foyerClient = FoyerClient()
        networkerSpy = NetworkerSpy()

        Environment.reset()
        Environment.shared.networker = networkerSpy

        Environment.shared.user
            .subscribe(output_user.observer)
            .disposed(by: disposeBag)
    }

    func test_login() {
        let payload = LoginRequestPayload(email: "test@test.com", password: "test123")
        foyerClient.accountLogin(payload) { _ in }
        let expectedResource: Resource<AppUser> = createExpectedResource(url: URL(string: "https://api.foyer.co/login")!, method: .post(payload))
        XCTAssertEqual(networkerSpy.loadCalled as! [Resource<AppUser>], [expectedResource])
        output_user.assertValues([nil])
    }

    func test_getFeatured() {
        foyerClient.getFeatured { _ in }
        let expectedResource: Resource<[Story]> = createExpectedResource(get: URL(string: "https://api.foyer.co/stories/featured")!)
        XCTAssertEqual(networkerSpy.loadCalled as! [Resource<[Story]>], [expectedResource])
    }

    func test_loadImage() {
        let imageUrl = URL(string: "https://test.com/test.jpg")!
        _ = foyerClient.loadImage(imageUrl) { _ in }
        let expectedResource: Resource<UIImage> = .init(get: imageUrl)
        XCTAssertEqual(networkerSpy.loadCalled as! [Resource<UIImage>], [expectedResource])
    }

    private func createExpectedResource<T: Codable, U>(url: URL, method: HttpMethod<U>) -> Resource<T> {
        var expectedResource = Resource<T>.init(url: url, method: method)
        expectedResource.urlRequest.setValue("4vbeFulPYdov1Lk46Jc96yaKCRTEhNyL", forHTTPHeaderField: "api-token")
        expectedResource.urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return expectedResource
    }

    private func createExpectedResource<T>(get url: URL) -> Resource<T> where T: Decodable {
        var expectedResource = Resource<T>.init(get: url)
        expectedResource.urlRequest.setValue("4vbeFulPYdov1Lk46Jc96yaKCRTEhNyL", forHTTPHeaderField: "api-token")
        expectedResource.urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return expectedResource
    }
}
