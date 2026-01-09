import asyncio
from playwright.async_api import async_playwright
import os
import base64

async def get_anses_cuil(dni, nombre, apellido, sexo, fecha_nacimiento):
    """
    Scrapes the ANSES website to get the CUIL constancy.
    sexo: 'M' for Masculino, 'F' for Femenino, 'X' for Incógnita
    fecha_nacimiento: 'DD/MM/YYYY'
    """
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
        page = await context.new_page()

        try:
            # Go to ANSES form
            await page.goto("https://servicioswww.anses.gob.ar/C2-ConstaCUIL/", wait_until="networkidle")

            # Fill the form
            await page.select_option("#TipoDocumento", "DU") # Standard DNI
            await page.fill("#NumeroDocumento", str(dni))
            await page.fill("#Nombre", nombre)
            await page.fill("#Apellido", apellido)
            
            # Sexo radio button
            sex_id = f"#sexo_{sexo.upper()}" # #sexo_M, #sexo_F, #sexo_X
            await page.click(sex_id)

            # Fecha Nacimiento
            await page.fill("#FechaNacimiento", fecha_nacimiento)

            # Submit
            # The button doesn't have an ID, using class
            await page.click("button.btn-cuil")

            # Wait for either result or error
            # If successful, a PDF is usually triggered or a new page is shown with a 'Descargar' button
            # Sometimes a captcha appears here if too many requests
            
            # Wait for navigation or specific element in results
            await page.wait_for_timeout(5000) # Simple wait for now

            # Check if there is an error message
            error_exists = await page.query_selector(".alert-danger")
            if error_exists:
                error_text = await error_exists.inner_text()
                return {"success": False, "error": f"ANSES Error: {error_text.strip()}"}

            # Usually the certificate is shown in a way that allows printing/downloading
            # Let's take a screenshot as proof or try to capture the PDF link
            screenshot_path = f"cuil_{dni}.png"
            await page.screenshot(path=screenshot_path)
            
            with open(screenshot_path, "rb") as image_file:
                encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
            
            # Clean up screenshot
            if os.path.exists(screenshot_path):
                os.remove(screenshot_path)

            return {
                "success": True, 
                "image_base64": encoded_string,
                "message": "Constancia generada (vía captura)"
            }

        except Exception as e:
            print(f"SCRAPER ERROR: {str(e)}")
            import traceback
            traceback.print_exc()
            return {"success": False, "error": str(e)}
        finally:
            await browser.close()

if __name__ == "__main__":
    # Test run
    # asyncio.run(get_anses_cuil("12345678", "JUAN", "PEREZ", "M", "01/01/1980"))
    pass
